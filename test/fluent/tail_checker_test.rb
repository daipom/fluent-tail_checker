# frozen_string_literal: true

require "test_helper"

class Fluent::TailCheckerTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::Fluent::TailChecker.const_defined?(:VERSION)
    end
  end

  test "something useful" do
    assert_equal("actual", "actual")
  end
end
