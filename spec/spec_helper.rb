# frozen_string_literal: true

if ENV["COVERAGE"] == "true"
  require "simplecov"
  require "coveralls"

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ])

  SimpleCov.start do
    command_name "spec"
    add_filter "spec"
  end
end

if RUBY_VERSION.to_f >= 2.5
  require "warning"
  Warning.ignore(//, /.*(listen|rouge|unicode_utils)/)
end

require "slideck"
require "stringio"

class StringIO
  def wait_readable(*)
    true
  end
end

module TestHelpers
  def unindent(string)
    string.gsub(/^#{string.scan(/^[ \t]+(?=\S)/).min}/, "")
  end

  def fixtures_path(*args)
    ::File.join(__dir__, "fixtures", *args)
  end
end

RSpec.configure do |config|
  config.include(TestHelpers)

  config.example_status_persistence_file_path = ".rspec_status"

  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.max_formatted_output_length = nil
    c.syntax = :expect
  end
end
