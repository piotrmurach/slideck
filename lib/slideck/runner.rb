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
require_relative "parser"
require_relative "presenter"
require_relative "renderer"
require_relative "tracker"

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
      presenter = build_presenter(*read_slides(filename), color)

      if watch
        listener = build_listener(presenter, filename)
        listener.start
      end

      presenter.start
    ensure
      listener && listener.stop
    end

    private

    # Read slides
    #
    # @param [String] filename
    #   the filename to read slides from
    #
    # @return [Array<Slideck::Metadata, Array<Hash>>]
    #
    # @api private
    def read_slides(filename)
      parse_slides(load_slides(filename))
    end

    # Load slides
    #
    # @param [String] filename
    #   the filename to load slides from
    #
    # @return [String]
    #
    # @api private
    def load_slides(filename)
      loader = Loader.new(::File)
      loader.load(filename)
    end

    # Parse slides
    #
    # @param [String] content
    #   the content with metadata and slides
    #
    # @return [Array<Slideck::Metadata, Array<Hash>>]
    #
    # @api private
    def parse_slides(content)
      metadata_parser = MetadataParser.new(::YAML, permitted_classes: [Symbol],
                                                   symbolize_names: true)
      parser = Parser.new(::StringScanner, metadata_parser)
      wrap_metadata(parser.parse(content))
    end

    # Wrap parsed slides metadata
    #
    # @param [Hash] deck
    #   the deck of parsed slides
    #
    # @return [Array<Slideck::Metadata, Hash>]
    #
    # @api private
    def wrap_metadata(deck)
      metadata_defaults = MetadataDefaults.new(Alignment, Margin)
      metadata = build_metadata(deck[:metadata], metadata_defaults)
      slides = deck[:slides].map do |slide|
        {content: slide[:content],
         metadata: build_metadata(slide[:metadata], {})}
      end

      [metadata, slides]
    end

    # Build metadata
    #
    # @param [Hash{Symbol => Object}] custom_metadata
    #   the custom metadata
    # @param [#merge] metadata_defaults
    #   the metadata defaults to merge with
    #
    # @return [Slideck::Metadata]
    #
    # @api private
    def build_metadata(custom_metadata, metadata_defaults)
      metadata_converter = MetadataConverter.new(Alignment, Margin)

      Metadata.from(metadata_converter, custom_metadata, metadata_defaults)
    end

    # Build presenter
    #
    # @param [Slideck::Metadata] metadata
    #   the configuration metadata
    # @param [Array<Hash>] slides
    #   the slides to present
    # @param [String, Symbol] color
    #   the color display out of always, auto or never
    #
    # @return [Slideck::Presenter]
    #
    # @api private
    def build_presenter(metadata, slides, color)
      reader = TTY::Reader.new(input: @input, output: @output, env: @env,
                               interrupt: :exit)
      converter = Converter.new(TTY::Markdown, color: color)
      renderer = Renderer.new(converter, Strings::ANSI, TTY::Cursor, metadata,
                              width: @screen.width, height: @screen.height)
      tracker = Tracker.for(slides.size)
      Presenter.new(slides, reader, renderer, tracker, @output)
    end

    # Build a listener for changes in a filename
    #
    # @param [Slideck::Presenter] presenter
    #   the presenter for slides
    # @param [String] filename
    #   the filename with slides
    #
    # @return [Listen::Listener]
    #
    # @api private
    def build_listener(presenter, filename)
      watched_dir = File.expand_path(File.dirname(filename))
      watched_file = File.expand_path(filename)
      Listen.to(watched_dir) do |changed_files, _, _|
        if changed_files.include?(watched_file)
          presenter.reload(*read_slides(filename)).render
        end
      end
    end
  end # Runner
end # Slideck
