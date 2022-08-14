# frozen_string_literal: true

module Slideck
  # Responsible for converting Markdown into terminal output
  #
  # @api private
  class Converter
    # Create a Converter instance
    #
    # @example
    #   Slideck::Converter.new(TTY::Markdown, color: false, width: 80)
    #
    # @param [TTY::Markdown] markdown_parser
    #   the markdown parser
    # @param [Boolean] color
    #   whether to render output in color or not
    # @param [Integer] width
    #   the terminal width
    #
    # @api public
    def initialize(markdown_parser, color: nil, width: nil)
      @markdown_parser = markdown_parser
      @color = color
      @width = width
      @conversion_settings = create_conversion_settings
    end

    # Convert content into terminal output
    #
    # @example
    #   converter.convert("#Title")
    #
    # @param [String] content
    #   the content to convert
    #
    # @return [String]
    #
    # @api public
    def convert(content)
      @markdown_parser.parse(content, **@conversion_settings)
    end

    private

    # The markdown conversion settings
    #
    # @return [Hash{Symbol => Integer,String}]
    #
    # @api private
    def create_conversion_settings
      {
        width: @width,
        color: @color ? "always" : "never"
      }
    end
  end # Converter
end # Slideck
