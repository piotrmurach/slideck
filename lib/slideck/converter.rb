# frozen_string_literal: true

module Slideck
  # Responsible for converting Markdown into terminal output
  #
  # @api private
  class Converter
    # Create a Converter instance
    #
    # @example
    #   Slideck::Converter.new(TTY::Markdown, color: false)
    #
    # @param [TTY::Markdown] markdown_parser
    #   the markdown parser
    # @param [Boolean] color
    #   whether to render output in color or not
    #
    # @api public
    def initialize(markdown_parser, color: nil)
      @markdown_parser = markdown_parser
      @color = color ? "always" : "never"
    end

    # Convert content into terminal output
    #
    # @example
    #   converter.convert("#Title", width: 80)
    #
    # @param [String] content
    #   the content to convert
    # @param [Hash, String, Symbol] symbols
    #   the converted content symbols
    # @param [Hash{Symbol => Array, String, Symbol}] theme
    #   the converted content theme
    # @param [Integer] width
    #   the slide width
    #
    # @return [String]
    #
    # @api public
    def convert(content, symbols: nil, theme: nil, width: nil)
      @markdown_parser.parse(
        content, color: @color, symbols: symbols, theme: theme, width: width)
    end
  end # Converter
end # Slideck
