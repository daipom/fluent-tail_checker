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

require "set"

module Fluent
  module TailChecker
    class DuplicatedPosChecker
      def initialize(posfile, follow_inodes)
        @posfile = posfile
        @follow_inodes = follow_inodes
      end

      def check
        duplicated_key_found = false
        key_set = Set.new
        duplicated_key_set = Set.new
        checked_key_counts = 0

        @posfile.watching_entries.map do |entry|
          @follow_inodes ? entry.ino : entry.path
        end.each do |key|
          checked_key_counts += 1
          next if key_set.add?(key)

          duplicated_key_found = true
          duplicated_key_set.add(key)
        end

        puts "Done duplication check for #{checked_key_counts} PosEntries."

        if duplicated_key_found
          log_issue(duplicated_key_set)
          return false
        end

        true
      end

      def log_issue(duplicated_keys)
        if @follow_inodes
          puts "Duplicated PosEntries are found. Unknown anomalies may be occurring. It is recommended to verify whether there is any log missing."
          puts "Duplicated inodes:"
        else
          puts "Duplicated PosEntries are found. This is a known log missing issue that was fixed in Fluentd v1.16.3 (fluent-package v5.0.2, td-agent v4.5.2). If you are using any version older than these, updating Fluentd will resolve the issue."
          puts "Duplicated paths:"
        end

        duplicated_keys.each do |key|
          puts "  #{key}"
        end
      end
    end
  end
end
