# frozen_string_literal: true

require "strings-ansi"
require "strscan"
require "tty-cursor"
require "tty-markdown"
require "tty-reader"
require "tty-screen"
require "yaml"

require_relative "alignment"
require_relative "converter"
require_relative "errors"
require_relative "loader"
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
    # Create a default Runner instance
    #
    # @example
    #   Slideck::Runner.default
    #
    # @return [Slideck::Runner]
    #
    # @api public
    def self.default
      new(TTY::Screen, $stdin, $stdout, {}, color: true)
    end

    # Create a Runner instance
    #
    # @example
    #   Slideck::Runner.new(TTY::Screen, $stdin, $stdout, false, {})
    #
    # @param [TTY::Screen] screen
    #   the terminal screen size
    # @param [IO] input
    #   the input stream
    # @param [IO] output
    #   the output stream
    # @param [Hash] env
    #   the environment variables
    # @param [Boolean] color
    #   whether or not to enable colored output
    #
    # @api public
    def initialize(screen, input, output, env, color: nil)
      @screen = screen
      @input = input
      @output = output
      @env = env
      @color = color
    end

    # Run the slides in a terminal
    #
    # @example
    #   runner.run("slides.md")
    #
    # @param [String] filename
    #   the filename with slides
    #
    # @return [void]
    #
    # @api public
    def run(filename)
      metadata, slides = parse_slides(load_slides(filename))

      reader = TTY::Reader.new(input: @input, output: @output, env: @env,
                               interrupt: :exit)
      screen_width = @screen.width
      converter = Converter.new(TTY::Markdown, color: @color,
                                               width: screen_width)
      renderer = Renderer.new(converter, Strings::ANSI, TTY::Cursor, metadata,
                              width: screen_width, height: @screen.height)
      tracker = Tracker.for(slides.size)
      presenter = Presenter.new(reader, renderer, tracker, @output)

      presenter.start(slides)
    end

    private

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
    # @return [Array<Slideck::Metadata, Hash>]
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
      metadata_defaults = MetadataDefaults.new(Alignment)
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
      metadata_converter = MetadataConverter.new(Alignment)

      Metadata.from(metadata_converter, custom_metadata, metadata_defaults)
    end
  end # Runner
end # Slideck
