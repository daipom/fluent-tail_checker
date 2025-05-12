# frozen_string_literal: true

require "test_helper"

class Fluent::TailChecker::CollectionRatioCheckerTest < Test::Unit::TestCase
  data("Normal ratio", [["test/data/log/foo.log", "test/data/log/bar.log"], 0.9, false, true])
  data("Too low ratio", [["test/data/log/foo.log", "test/data/log/bar.log"], 0.7, false, false])
  data("Normal ratio with follow_inodes", [["test/data/log/foo.log", "test/data/log/bar.log"], 0.9, true, true])
  data("Too low ratio with follow_inodes", [["test/data/log/foo.log", "test/data/log/foo.log.1"], 0.7, true, false])
  test "Check should return false when too low collection ratio is detected" do |(paths, ratio, follow_inodes, expected)|
    pos_entries = paths.map do |path|
      stat = Fluent::FileWrapper.stat(path)
      Fluent::TailChecker::PosEntry.new(path, stat.size * ratio, stat.ino)
    end
    pos_file = Fluent::TailChecker::PosFile.new(pos_entries)
    checker = Fluent::TailChecker::CollectionRatioChecker.new(pos_file, follow_inodes)

    result = checker.check

    assert_equal(expected, result)
  end
end
