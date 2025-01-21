# frozen_string_literal: true

require_relative "lib/dep_inject/version"

Gem::Specification.new do |spec|
  spec.name = "dep-inject"
  spec.version = DepInject::VERSION
  spec.authors = ["christophenonato"]
  spec.email = ["chr.nonato@protonmail.com"]

  spec.summary = "A lightweight dependency injection gem"
  spec.description = "DepInject helps to inject dependencies into your classes, enforcing public method restrictions."
  spec.homepage = "https://github.com/christophenonato/dep-inject"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/christophenonato/dep-inject"

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
end
