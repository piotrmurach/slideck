# frozen_string_literal: true

require_relative "slideck/runner"
require_relative "slideck/version"

# Present Markdown-powered slide decks in a terminal
module Slideck
  # Run slides deck
  #
  # @example
  #   Slideck.run
  #
  # @param [String] file
  #   the file with Markdown slides
  #
  # @return [void]
  #
  # @api public
  def self.run(file = ARGV.first)
    Runner.default.run(file)
  end
end # Slideck
