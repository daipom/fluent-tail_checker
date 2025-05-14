# frozen_string_literal: true

require_relative "lib/fluent/tail_checker/version"

Gem::Specification.new do |spec|
  spec.name = "fluent-tail_checker"
  spec.version = Fluent::TailChecker::VERSION
  spec.authors = ["Daijiro Fukuda"]
  spec.email = ["fukuda@clear-code.com"]

  spec.summary = "A script to check that in_tail plugin of Fluentd is working properly."
  spec.description = "A script to check that in_tail plugin of Fluentd is working properly."
  spec.homepage = "https://github.com/clear-code/fluent-tail_checker"
  spec.license = "Apache-2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "fluentd", "~> 1.0"
end
