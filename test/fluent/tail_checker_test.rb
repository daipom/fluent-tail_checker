# frozen_string_literal: true

require "test_helper"

class Fluent::TailCheckerTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::Fluent::TailChecker.const_defined?(:VERSION)
    end
  end

  sub_test_case "Parse args" do
    data(
      "Minimum",
      [
        ["/path/to/pos"],
        { pos_filepaths: ["/path/to/pos"], follow_inodes: false, collection_ratio_threshold: 0.5 },
      ]
    )
    data(
      "Full",
      [
        ["--follow-inodes", "--ratio", "0.7", "/path/to/pos", "/path/to/pos2"],
        { pos_filepaths: ["/path/to/pos", "/path/to/pos2"], follow_inodes: true, collection_ratio_threshold: 0.7 },
      ]
    )
    data(
      "--follow_inodes (using underscore)",
      [
        ["--follow_inodes", "/path/to/pos"],
        { pos_filepaths: ["/path/to/pos"], follow_inodes: true, collection_ratio_threshold: 0.5 },
      ]
    )
    test "Correct args" do |(args, expected)|
      tail_check = Fluent::TailChecker::TailCheck.new

      tail_check.parse_command_line(args)

      result = {
        pos_filepaths: tail_check.instance_variable_get(:@pos_filepaths),
        follow_inodes: tail_check.instance_variable_get(:@follow_inodes),
        collection_ratio_threshold: tail_check.instance_variable_get(:@collection_ratio_threshold),
      }
      assert_equal(expected, result)
    end

    data("Invalid options", ["--foo", "/path/to/pos"])
    data("--ratio: invalid value: ", ["--ratio", "70", "/path/to/pos"])
    test "Raise error for invalid options" do |args|
      tail_check = Fluent::TailChecker::TailCheck.new

      assert_raise do
        tail_check.parse_command_line(args)
      end
    end
  end

  sub_test_case "Validate pos_file paths" do
    data(
      "Mixed existant and nonexistant paths",
      [
        ["test/data/pos_normal", "foo", "test/data/pos_follow_inodes_normal", "bar"],
        ["test/data/pos_normal", "test/data/pos_follow_inodes_normal"],
      ]
    )
    test "Exclude nonexistant paths" do |(paths, expected)|
      tail_check = Fluent::TailChecker::TailCheck.new

      validated_paths = tail_check.validate_paths(paths).to_a

      assert_equal(expected, validated_paths)
    end
  end

  sub_test_case "Check" do
    data("No pos_file", [[], false, false])
    data("No pos_file with follow_inodes", [[], true, false])
    data("Normal", [["test/data/pos_normal"], false, true])
    data("Duplicated unwatched paths", [["test/data/pos_duplicate_unwatched_path"], false, false])
    data("Normal with follow_inodes", [["test/data/pos_follow_inodes_normal"], true, true])
    data("Duplicated unwatched inodes with follow_inodes", [["test/data/pos_duplicate_unwatched_inode"], true, false])
    data("Duplicated unwatched paths with follow_inodes", [["test/data/pos_duplicate_unwatched_path"], true, true])
    data("Normal multiple", [["test/data/pos_follow_inodes_normal", "test/data/pos_duplicate_unwatched_path"], true, true])
    data("Anomaly multiple", [["test/data/pos_follow_inodes_normal", "test/data/pos_duplicate_unwatched_inode"], true, false])
    test "Return false when duplicated pos is detected or there is no target" do |(paths, follow_inodes, expected)|
      tail_check = Fluent::TailChecker::TailCheck.new
      tail_check.instance_variable_set(:@pos_filepaths, paths)
      tail_check.instance_variable_set(:@follow_inodes, follow_inodes)

      result = tail_check.check

      assert_equal(expected, result)
    end

    data("Acceptable ratio", [0.9, true])
    data("Too low ratio", [0.3, false])
    test "Return false when too low collection ratio is detected" do |(stub_ratio, expected)|
      any_instance_of(Fluent::TailChecker::CollectionRatioChecker) do |checker|
        mock(checker).get_file_size_from_path(anything).at_least(1) do |pos_entry|
          # collection ratio = pos / file size
          # => file size = pos / collection ratio
          pos_entry.pos / stub_ratio
        end
        mock(checker).get_file_size_from_inode.never
      end

      tail_check = Fluent::TailChecker::TailCheck.new
      tail_check.instance_variable_set(:@pos_filepaths, ["test/data/pos_normal"])

      result = tail_check.check

      assert_equal(expected, result)
    end

    data("Acceptable ratio", [0.9, true])
    data("Too low ratio", [0.3, false])
    test "Return false when too low collection ratio is detected (follow_inodes)" do |(stub_ratio, expected)|
      any_instance_of(Fluent::TailChecker::CollectionRatioChecker) do |checker|
        mock(checker).get_file_size_from_path.never
        mock(checker).get_file_size_from_inode(anything).at_least(1) do |pos_entry|
          # collection ratio = pos / file size
          # => file size = pos / collection ratio
          pos_entry.pos / stub_ratio
        end
      end

      tail_check = Fluent::TailChecker::TailCheck.new
      tail_check.instance_variable_set(:@pos_filepaths, ["test/data/pos_follow_inodes_normal"])
      tail_check.instance_variable_set(:@follow_inodes, true)

      result = tail_check.check

      assert_equal(expected, result)
    end
  end
end
