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
        { pos_filepaths: ["/path/to/pos"], follow_inodes: false },
      ]
    )
    data(
      "Full",
      [
        ["--follow_inodes", "/path/to/pos", "/path/to/pos2"],
        { pos_filepaths: ["/path/to/pos", "/path/to/pos2"], follow_inodes: true },
      ]
    )
    test "Correct args" do |(args, expected)|
      tail_check = Fluent::TailChecker::TailCheck.new

      tail_check.parse_command_line(args)

      result = {
        pos_filepaths: tail_check.instance_variable_get(:@pos_filepaths),
        follow_inodes: tail_check.instance_variable_get(:@follow_inodes),
      }
      assert_equal(expected, result)
    end

    data("Invalid options", ["--foo", "/path/to/pos"])
    test "Raise error for invalid options" do |args|
      tail_check = Fluent::TailChecker::TailCheck.new

      assert_raise(OptionParser::InvalidOption) do
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
    test "Return false when an anomaly is detected or there is no target" do |(paths, follow_inodes, expected)|
      tail_check = Fluent::TailChecker::TailCheck.new
      tail_check.instance_variable_set(:@pos_filepaths, paths)
      tail_check.instance_variable_set(:@follow_inodes, follow_inodes)

      result = tail_check.check

      assert_equal(expected, result)
    end
  end
end
