# frozen_string_literal: true

source "https://rubygems.org"

gemspec

if RUBY_VERSION == "2.0.0"
  gem "json", "2.4.1"
  gem "kramdown", "1.16.2"
end

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.4.0")
  gem "listen", "3.0.8"
end

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.1.0")
  gem "rspec-benchmark", "~> 0.6"
end

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.5.0")
  gem "warning", "~> 1.3"
end

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.7.0")
  gem "coveralls_reborn", "~> 0.28.0"
  gem "rubocop-performance", "~> 1.20"
  gem "rubocop-rake", "~> 0.6"
  gem "rubocop-rspec", "~> 2.22"
  gem "simplecov", "~> 0.22.0"
end
