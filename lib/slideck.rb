# frozen_string_literal: true

require "tty-screen"

require_relative "slideck/cli"
require_relative "slideck/errors"
require_relative "slideck/runner"
require_relative "slideck/version"

# Present Markdown-powered slide decks in a terminal
module Slideck
  # Run slides deck
  #
  # @example
  #   Slideck.run
  #
  # @param [Array<String>] cmd_args
  #   the command arguments
  # @param [Hash{String => String}] env
  #   the environment variables
  #
  # @return [void]
  #
  # @api public
  def self.run(cmd_args = ARGV, env = ENV)
    runner = Runner.new(TTY::Screen, $stdin, $stdout, env)
    cli = CLI.new(runner, $stdout, $stderr)
    cli.start(cmd_args, env)
  end
end # Slideck
