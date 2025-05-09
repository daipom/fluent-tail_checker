# frozen_string_literal: true

require_relative "lib/fluent/tail_checker/version"

Gem::Specification.new do |spec|
  spec.name = "fluent-tail_checker"
  spec.version = Fluent::TailChecker::VERSION
  spec.authors = ["Daijiro Fukuda"]
  spec.email = ["fukuda@clear-code.com"]

  spec.summary = "summary" # TODO
  spec.description = "description" # TODO
  # spec.homepage = "TODO: Put your gem's website or public repo URL here."

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

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
