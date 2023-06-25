# frozen_string_literal: true

require_relative "lib/slideck/version"

Gem::Specification.new do |spec|
  spec.name = "slideck"
  spec.version = Slideck::VERSION
  spec.authors = ["Piotr Murach"]
  spec.email = ["piotr@piotrmurach.com"]
  spec.summary = "Terminal tool for presenting Markdown-powered slide decks."
  spec.description = "Terminal tool for presenting Markdown-powered slide decks."
  spec.homepage = "https://ttytoolkit.org"
  spec.license = "AGPL-3.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["bug_tracker_uri"] = "https://github.com/piotrmurach/slideck/issues"
  spec.metadata["changelog_uri"] = "https://github.com/piotrmurach/slideck/blob/master/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/slideck"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["source_code_uri"] = "https://github.com/piotrmurach/slideck"

  spec.files = Dir["lib/**/*"]
  spec.extra_rdoc_files = ["README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.bindir = "exe"
  spec.executables = ["slideck"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.0.0"

  spec.add_dependency "listen", "~> 3.0"
  spec.add_dependency "strings-ansi", "~> 0.2.0"
  spec.add_dependency "tty-cursor", "~> 0.7.1"
  spec.add_dependency "tty-markdown", "~> 0.7.2"
  spec.add_dependency "tty-option", "~> 0.3.0"
  spec.add_dependency "tty-reader", "~> 0.9.0"
  spec.add_dependency "tty-screen", "~> 0.8.1"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0"
end
