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
          Example: tailcheck --follow_inodes /path/to/pos_with_follow_inodes
          Options:

        BANNER

        parser.on("--follow_inodes", "Check the specified pos files with the condition that the follow_inodes feature is enabled.", "Default: Disabled") do
          @follow_inodes = true
        end

        @pos_filepaths = parser.parse(argv)
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
          succeeded = CollectionRatioChecker.new(pos_file, @follow_inodes).check && succeeded
        end

        puts "\nAll check completed."

        unless succeeded
          puts "Some anomalies are found. Please check whether there is any log loss."
          # TODO add message about how to concact the community or us.
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
