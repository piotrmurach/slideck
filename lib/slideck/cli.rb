# frozen_string_literal: true

require "tty-option"

module Slideck
  # Responsible for parsing command line inputs
  #
  # @api private
  class CLI
    include TTY::Option

    usage do
      no_command

      desc "Present Markdown-powered slide decks in the terminal"

      desc "Controls:",
           "  First   ^",
           "  Go to   1..n+g",
           "  Last    $",
           "  Next    n, l, Right, Spacebar",
           "  Prev    p, h, Left, Backspace",
           "  Reload  r, Ctrl+l",
           "  Quit    q, Esc"

      example "Start presentation",
              "$ #{program} slides.md"
    end

    argument :file

    option :color do
      long "--color WHEN"
      default "auto"
      permit %w[always auto never]
      desc "When to color output"
    end

    flag :debug do
      short "-d"
      long "--debug"
      desc "Run in debug mode"
    end

    flag :help do
      short "-h"
      long "--help"
      desc "Print usage"
    end

    flag :no_color do
      long "--no-color"
      desc "Do not color output. Identical to --color=never"
    end

    flag :version do
      short "-v"
      long "--version"
      desc "Print version"
    end

    flag :watch do
      short "-w"
      long "--watch"
      desc "Watch for changes in the file with slides"
    end

    # The pattern to detect color option
    #
    # @return [Regexp]
    #
    # @api private
    COLOR_OPTION_PATTERN = /^--color/.freeze
    private_constant :COLOR_OPTION_PATTERN

    # The no color environment variable name
    #
    # @return [String]
    #
    # @api private
    NO_COLOR_ENV_NAME = "NO_COLOR"
    private_constant :NO_COLOR_ENV_NAME

    # Create a CLI instance
    #
    # @example
    #   Slideck::CLI.new(runner, $stdout, $stderr)
    #
    # @param [Slideck::Runner] runner
    #   the runner used to display slides
    # @param [IO] output
    #   the output stream
    # @param [IO] error_output
    #   the error output stream
    #
    # @api public
    def initialize(runner, output, error_output)
      @runner = runner
      @output = output
      @error_output = error_output
    end

    # Start presenting slides deck
    #
    # @example
    #   cli.start(["slides.md"], {})
    #
    # @param [Array<String>] cmd_args
    #   the command arguments
    # @param [Hash{String => String}] env
    #   the environment variables
    #
    # @raise [SystemExit]
    #
    # @return [void]
    #
    # @api public
    def start(cmd_args, env)
      parse(cmd_args, env)

      print_version || print_help || print_errors

      rescue_errors do
        @runner.run(params[:file],
                    color: color(no_color_env?(cmd_args, env)),
                    watch: params[:watch])
      end
    end

    private

    # Print version
    #
    # @raise [SystemExit]
    #
    # @return [nil]
    #
    # @api private
    def print_version
      return unless params[:version]

      @output.puts VERSION
      exit
    end

    # Print help
    #
    # @raise [SystemExit]
    #
    # @return [nil]
    #
    # @api private
    def print_help
      return unless params[:help] || file_missing?

      @output.print help
      exit
    end

    # Check whether a file is missing
    #
    # @return [Boolean]
    #
    # @api private
    def file_missing?
      params.errors.size == 1 && params[:file].nil?
    end

    # Print parsing errors
    #
    # @raise [SystemExit]
    #
    # @return [nil]
    #
    # @api private
    def print_errors
      return unless params.errors.any?

      @error_output.puts params.errors.summary
      exit 1
    end

    # Rescue errors
    #
    # @yield a block with error rescue
    #
    # @raise [SystemExit]
    #
    # @return [void]
    #
    # @api private
    def rescue_errors
      yield
    rescue Slideck::Error => err
      raise err if params[:debug]

      @error_output.puts "Error: #{err}"
      exit 1
    end

    # Check whether no color environment variable is present
    #
    # @param [Array<String>] cmd_args
    #   the command arguments
    # @param [Hash{String => String}] env
    #   the environment variables
    #
    # @return [Boolean]
    #
    # @api private
    def no_color_env?(cmd_args, env)
      color_option_given = cmd_args.grep(COLOR_OPTION_PATTERN).any?
      no_color_env_given = !env[NO_COLOR_ENV_NAME].to_s.empty?

      !color_option_given && no_color_env_given
    end

    # Read when to color output
    #
    # @param [Boolean] no_color_env
    #   the no color environment variable presence
    #
    # @return [String, Symbol]
    #
    # @api private
    def color(no_color_env)
      params[:no_color] || no_color_env ? :never : params[:color]
    end
  end # CLI
end # Slideck
