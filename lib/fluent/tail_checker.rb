# frozen_string_literal: true

require_relative "tail_checker/version"

module Fluent
  module TailChecker
    def self.run
      puts Fluent::TailChecker::VERSION
    end
  end
end
