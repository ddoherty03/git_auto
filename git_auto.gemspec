# frozen_string_literal: true

require_relative "lib/git_auto/version"

Gem::Specification.new do |spec|
  spec.name = "git_auto"
  spec.version = GitAuto::VERSION
  spec.authors = ["Daniel E. Doherty"]
  spec.email = ["ded@ddoherty.net"]

  spec.summary = "Automatically commit changes in given directories"
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "https://github.com/ddoherty03/git_auto"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    %x(git ls-files -z).split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "bin"
  spec.executables = ['git_auto']
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "activesupport"
end
