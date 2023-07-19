# frozen_string_literal: true

require "listen"
require "strings-ansi"
require "strscan"
require "tty-cursor"
require "tty-markdown"
require "tty-reader"
require "yaml"

require_relative "alignment"
require_relative "converter"
require_relative "loader"
require_relative "margin"
require_relative "metadata"
require_relative "metadata_converter"
require_relative "metadata_defaults"
require_relative "metadata_parser"
require_relative "metadata_wrapper"
require_relative "parser"
require_relative "presenter"
require_relative "renderer"
require_relative "tracker"
require_relative "transformer"

module Slideck
  # Parse and display slides
  #
  # @api private
  class Runner
    # Create a Runner instance
    #
    # @example
    #   Slideck::Runner.new(TTY::Screen, $stdin, $stdout, {})
    #
    # @param [TTY::Screen] screen
    #   the terminal screen size
    # @param [IO] input
    #   the input stream
    # @param [IO] output
    #   the output stream
    # @param [Hash] env
    #   the environment variables
    #
    # @api public
    def initialize(screen, input, output, env)
      @screen = screen
      @input = input
      @output = output
      @env = env
    end

    # Run the slides in a terminal
    #
    # @example
    #   runner.run("slides.md", color: :always, watch: true)
    #
    # @param [String] filename
    #   the filename with slides
    # @param [String, Symbol] color
    #   the color display out of always, auto or never
    # @param [Boolean] watch
    #   whether to watch for changes in a filename
    #
    # @return [void]
    #
    # @api public
    def run(filename, color: nil, watch: nil)
      transformer = build_transformer
      presenter = build_presenter(color) { transformer.read(filename) }

      if watch
        listener = build_listener(filename) { presenter.reload.render }
        listener.start
      end

      presenter.start
    ensure
      listener && listener.stop
    end

    private

    # Build transformer
    #
    # @return [Slideck::Transformer]
    #
    # @api private
    def build_transformer
      loader = Loader.new(::File)
      Transformer.new(loader, build_parser, build_metadata_wrapper)
    end

    # Build parser
    #
    # @return [Slideck::Parser]
    #
    # @api private
    def build_parser
      metadata_parser = MetadataParser.new(
        ::YAML, permitted_classes: [Symbol], symbolize_names: true)
      Parser.new(::StringScanner, metadata_parser)
    end

    # Build metadata wrapper
    #
    # @return [Slideck::MetadataWrapper]
    #
    # @api private
    def build_metadata_wrapper
      metadata_converter = MetadataConverter.new(Alignment, Margin)
      metadata_defaults = MetadataDefaults.new(Alignment, Margin)
      MetadataWrapper.new(Metadata, metadata_converter, metadata_defaults)
    end

    # Build presenter
    #
    # @param [String, Symbol] color
    #   the color display out of always, auto or never
    # @param [Proc] reloader
    #   the metadata and slides reloader
    #
    # @return [Slideck::Presenter]
    #
    # @api private
    def build_presenter(color, &reloader)
      reader = TTY::Reader.new(input: @input, output: @output, env: @env,
                               interrupt: :exit)
      converter = Converter.new(TTY::Markdown, color: color)
      renderer = Renderer.new(converter, Strings::ANSI, TTY::Cursor,
                              width: @screen.width, height: @screen.height)
      tracker = Tracker.for(0)
      Presenter.new(reader, renderer, tracker, @screen, @output, &reloader)
    end

    # Build a listener for changes in a filename
    #
    # @param [String] filename
    #   the filename with slides
    #
    # @return [Listen::Listener]
    #
    # @api private
    def build_listener(filename)
      watched_dir = File.expand_path(File.dirname(filename))
      watched_file = File.expand_path(filename)
      Listen.to(watched_dir) do |changed_files, _, _|
        yield if changed_files.include?(watched_file)
      end
    end
  end # Runner
end # Slideck
