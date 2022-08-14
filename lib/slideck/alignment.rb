# frozen_string_literal: true

module Slideck
  # Responsible for accessing alignment configuration
  #
  # @api private
  class Alignment
    # The allowed horizontal alignment values
    #
    # @return [Array<String>]
    #
    # @api private
    HORIZONTAL_VALUES = %w[left center right].freeze
    private_constant :HORIZONTAL_VALUES

    # The allowed vertical alignment values
    #
    # @return [Array<String>]
    #
    # @api private
    VERTICAL_VALUES = %w[top center bottom].freeze
    private_constant :VERTICAL_VALUES

    # Create an Alignment instance from a string
    #
    # @example
    #   Slideck::Alignment.from("right top")
    #
    # @example
    #   Slideck::Alignment.from("right,top")
    #
    # @param [String] value
    #   the value to extract alignments from
    # @param [String] default
    #   the default vertical alignment
    #
    # @return [Slideck::Alignment]
    #
    # @api public
    def self.from(value, default: "center")
      horizontal, vertical = *value.split(/[ ,]+/)
      vertical = default if vertical.nil?

      new(horizontal, vertical)
    end

    # Create an Alignment instance with an array-like initialiser
    #
    # @example
    #   Slideck::Alignment["right", "top"]
    #
    # @param [String] horizontal
    #   the horizontal value
    # @param [String] vertical
    #   the vertical value
    #
    # @return [Slideck::Alignment]
    #
    # @api public
    def self.[](horizontal, vertical)
      new(horizontal, vertical)
    end

    # The horizontal alignment
    #
    # @example
    #   alignemnt.horizontal
    #
    # @return [String]
    #
    # @api public
    attr_reader :horizontal

    # The vertical alignment
    #
    # @example
    #   alignment.vertical
    #
    # @return [String]
    #
    # @api public
    attr_reader :vertical

    # Create an Alignment
    #
    # @example
    #   Slideck::Alignment.new("left", "top")
    #
    # @param [String] horizontal
    #   the horizontal value
    # @param [String] vertical
    #   the vertical value
    #
    # @raise [Slideck::InvalidArgumentError]
    #
    # @api private
    def initialize(horizontal, vertical)
      @horizontal = validate_horizontal(horizontal)
      @vertical = validate_vertical(vertical)

      freeze
    end
    private_class_method :new

    # Determine equivalence with another object
    #
    # @example
    #   alignment == other
    #
    # @param [Object] other
    #   the other object to determine equivalence with
    #
    # @return [Boolean]
    #   true if this object is equivalent to the other, false otherwise
    #
    # @api public
    def ==(other)
      other.is_a?(self.class) &&
        horizontal == other.horizontal && vertical == other.vertical
    end

    # Determine equality with another object
    #
    # @example
    #   alignment.eql?(other)
    #
    # @param [Object] other
    #   the other object to determine equality with
    #
    # @return [Boolean]
    #   true if this object is equal to the other, false otherwise
    #
    # @api public
    def eql?(other)
      instance_of?(other.class) &&
        horizontal.eql?(other.horizontal) && vertical.eql?(other.vertical)
    end

    # Generate hash value of this alignment
    #
    # @example
    #   alignment.hash
    #
    # @return [Integer]
    #
    # @api public
    def hash
      [self.class, horizontal, vertical].hash
    end

    # Convert this alignment into an array
    #
    # @example
    #   alignment.to_a
    #
    # @return [Array<String, String>]
    #
    # @api public
    def to_a
      [horizontal, vertical]
    end

    private

    # Check whether a value is allowed as horizontal alignment
    #
    # @param [String] value
    #   the horizontal alignment value to check
    #
    # @raise [Slideck::InvalidArgumentError]
    #
    # @return [String]
    #
    # @api private
    def validate_horizontal(value)
      return value if HORIZONTAL_VALUES.include?(value)

      raise InvalidArgumentError,
            "unknown '#{value}' horizontal alignment. " \
            "Valid value is: left, center and right."
    end

    # Check whether a vlaue is allowed as vertical alignment
    #
    # @param [String] value
    #   the vertical alignment value to check
    #
    # @raise [Slideck::InvalidArgumentError]
    #
    # @return [String]
    #
    # @api private
    def validate_vertical(value)
      return value if VERTICAL_VALUES.include?(value)

      raise InvalidArgumentError,
            "unknown '#{value}' vertical alignment. " \
            "Valid value is: top, center and bottom."
    end
  end # Alignment
end # Slideck
