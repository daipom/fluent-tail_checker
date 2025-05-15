# frozen_string_literal: true

# Copyright 2025 Daijiro Fukuda
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "optparse"

require_relative "pos"
require_relative "duplicated_pos_checker"
require_relative "collection_ratio_checker"

module Fluent
  module TailChecker
    class TailCheck
      def initialize
        @pos_filepaths = []
        @follow_inodes = false
        @collection_ratio_threshold = 0.5
      end

      def run(argv=ARGV)
        parse_command_line(argv)
        @pos_filepaths = validate_paths(@pos_filepaths).to_a
        check
      end

      def parse_command_line(argv)
        parser = OptionParser.new
        parser.version = VERSION
        parser.banner = <<~BANNER
          Usage: tailcheck [OPTIONS] POS_FILE...
          Example: tailcheck /path/to/pos1 /path/to/pos2
          Example: tailcheck /path/to/pos/*
          Example: tailcheck --follow-inodes /path/to/pos_with_follow_inodes

          If you have any issues with this command, please report it to https://github.com/clear-code/fluent-tail_checker/issues.

          Options:
        BANNER

        parser.on("--follow-inodes", "Check the specified pos files with the condition that the follow_inodes feature is enabled.", "Default: Disabled") do
          @follow_inodes = true
        end
        parser.on("--ratio NUM", Float, "Minimum ratio of collection of each target log file to accept.", "Default: #{@collection_ratio_threshold}") do |v|
          @collection_ratio_threshold = v
        end

        begin
          @pos_filepaths = parser.parse(argv)

          if @collection_ratio_threshold < 0 or @collection_ratio_threshold > 1
            raise OptionParser::InvalidArgument, "--ratio #{@collection_ratio_threshold} must be an decimal from 0 to 1."
          end
        rescue OptionParser::ParseError => e
          $stderr.puts e, "", parser.help, ""
          raise
        end
      end

      def validate_paths(paths)
        Enumerator.new do |y|
          paths.each do |path|
            unless FileTest.exist?(path)
              $stderr.puts "File does not exist. Skipped. Path: #{path}"
              next
            end

            y << path
          end
        end
      end

      def check
        if @pos_filepaths.empty?
          $stderr.puts "No pos_file to be checked. Please specify valid pos_file paths."
          return false
        end

        succeeded = true

        @pos_filepaths.each do |path|
          puts "\nCheck #{path}."
          pos_file = try_to_open_pos_file(path)
          next if pos_file.nil?

          succeeded = DuplicatedPosChecker.new(pos_file, @follow_inodes).check && succeeded
          succeeded = CollectionRatioChecker.new(pos_file, @follow_inodes, @collection_ratio_threshold).check && succeeded
        end

        puts "\nAll check completed."

        unless succeeded
          puts "Some anomalies are found. Please check the logs for details."
          puts "If you have any questions or issues, please report them to the following:"
          puts "  Fluentd Q&A: https://github.com/fluent/fluentd/discussions/categories/q-a"
          puts "  Fluentd Q&A (日本語用): https://github.com/fluent/fluentd/discussions/categories/q-a-japanese"
          puts "  About this command (日本語可): https://github.com/clear-code/fluent-tail_checker/issues"
          return false
        end

        puts "There is no anomalies."
        true
      end

      def try_to_open_pos_file(path)
        PosFile.load(path)
      rescue => e
        $stderr.puts "Can not open the file. Skipped. Path: #{path}, Error: #{e}"
      end
    end
  end
end
