# frozen_string_literal: true

module Slideck
  # Responsible for converting Markdown into terminal output
  #
  # @api private
  class Converter
    # The allowed color display modes
    #
    # @return [Array<String>]
    #
    # @api private
    COLOR_DISPLAY_MODES = %w[always auto never].freeze
    private_constant :COLOR_DISPLAY_MODES

    # Create a Converter instance
    #
    # @example
    #   Slideck::Converter.new(TTY::Markdown, color: false)
    #
    # @param [TTY::Markdown] markdown_parser
    #   the markdown parser
    # @param [String, Symbol] color
    #   the color display out of always, auto or never
    #
    # @api public
    def initialize(markdown_parser, color: nil)
      @markdown_parser = markdown_parser
      @color = validate_color(color)
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

    private

    # Validate color display mode
    #
    # @param [Object] value
    #   the value to validate
    #
    # @raise [Slideck::InvalidArgumentError]
    #
    # @return [String, Symbol]
    #
    # @api private
    def validate_color(value)
      return value if COLOR_DISPLAY_MODES.include?(value.to_s)

      raise_invalid_color_error(value)
    end

    # Raise an error for an invalid color
    #
    # @param [Object] value
    #   the invalid value
    #
    # @raise [Slideck::InvalidArgumentError]
    #
    # @return [void]
    #
    # @api private
    def raise_invalid_color_error(value)
      raise InvalidArgumentError,
            "invalid value for color: #{value.inspect}.\n" \
            "The color needs to be one of always, auto or never."
    end
  end # Converter
end # Slideck
