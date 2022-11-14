# frozen_string_literal: true

module Slideck
  # Responsible for accessing margin configuration
  #
  # @api private
  class Margin
    # The pattern to validate input contains only integers
    #
    # @return [Regexp]
    #
    # @api private
    INTEGERS_ONLY_PATTERN = /^[\d, ]+$/.freeze
    private_constant :INTEGERS_ONLY_PATTERN

    # The pattern to detect integers separator
    #
    # @return [Regexp]
    #
    # @api private
    INTEGERS_SEPARATOR = /[ ,]+/.freeze
    private_constant :INTEGERS_SEPARATOR

    # The allowed margin side names
    #
    # @return [Array<Symbol>]
    #
    # @api private
    SIDE_NAMES = %i[top right bottom left].freeze
    private_constant :SIDE_NAMES

    # Create a Margin instance from a value
    #
    # @example
    #   Slideck::Margin.from(1)
    #
    # @example
    #   Slideck::Margin.from([1, 2])
    #
    # @example
    #   Slideck::Margin.from({top: 1, left: 2})
    #
    # @example
    #   Slideck::Margin.from("1, 2")
    #
    # @param [Object] value
    #   the value to create a margin from
    #
    # @raise [Slideck::InvalidArgumentError]
    #
    # @return [Slideck::Margin]
    #
    # @api public
    def self.from(value)
      if value.is_a?(Hash)
        from_hash(value)
      elsif (converted = convert_to_array(value))
        from_array(converted)
      else
        raise_invalid_margin_error(value)
      end
    end

    # Create a Margin instance with an array-like initialiser
    #
    # @example
    #   Slideck::Margin[1, 2]
    #
    # @example
    #   Slideck::Margin[1, 2, 3, 4]
    #
    # @param [Array<Integer>] values
    #   the values to convert to a margin
    #
    # @return [Slideck::Margin]
    #
    # @api public
    def self.[](*values)
      from_array(values)
    end

    # Create a Margin instance from an array
    #
    # @example
    #   Slideck::Margin.from_array([1, 2])
    #
    # @param [Array] value
    #   the value to convert to a margin
    #
    # @raise [Slideck::InvalidArgumentError]
    #
    # @return [Slideck::Margin]
    #
    # @api public
    def self.from_array(value)
      case value.size
      when 1 then new(*(value * 4))
      when 2 then new(*(value * 2))
      when 3 then new(*value, value[1])
      when 4 then new(*value)
      else raise_invalid_margin_as_array_error(value)
      end
    end

    # Create a Margin instance from a hash
    #
    # @example
    #   Slideck::Margin.from_hash{top: 1, left: 2})
    #
    # @param [Hash] value
    #   the hash value to convert to a margin
    #
    # @raise [Slideck::InvalidArgumentError]
    #
    # @return [Slideck::Margin]
    #
    # @api public
    def self.from_hash(value)
      unless (invalid = (value.keys - SIDE_NAMES)).empty?
        raise_invalid_margin_as_hash_error(invalid)
      end

      new(*value.values_at(*SIDE_NAMES).map { |val| val.nil? ? 0 : val })
    end

    # Convert a value into an array
    #
    # @param [Object] value
    #   the value to convert into an array
    #
    # @return [Array<Integer>, nil]
    #
    # @api private
    def self.convert_to_array(value)
      if value.is_a?(Numeric)
        [value]
      elsif value.is_a?(String) && value =~ INTEGERS_ONLY_PATTERN
        value.split(INTEGERS_SEPARATOR).map(&:to_i)
      elsif value.is_a?(Array)
        value
      end
    end
    private_class_method :convert_to_array

    # Raise an error when the value is invalid
    #
    # @param [Object] value
    #   the invalid value
    #
    # @raise [Slideck::InvalidArgumentError]
    #
    # @return [void]
    #
    # @api private
    def self.raise_invalid_margin_error(value)
      raise InvalidArgumentError,
            "invalid value for margin: #{value.inspect}.\n" \
            "The margin needs to be an integer, a string of " \
            "integers, an array of integers or " \
            "a hash of side names and integer values."
    end
    private_class_method :raise_invalid_margin_error

    # Raise an error when the array has a wrong number of values
    #
    # @param [Array<Integer>] values
    #   the margin values
    #
    # @raise [Slideck::InvalidArgumentError]
    #
    # @return [void]
    #
    # @api private
    def self.raise_invalid_margin_as_array_error(values)
      raise InvalidArgumentError,
            "wrong number of integers for margin: " \
            "#{values.join(", ").inspect}.\n" \
            "The margin needs to be specified with one, two, three " \
            "or four integers."
    end
    private_class_method :raise_invalid_margin_as_array_error

    # Raise an error when the hash has an invalid side name
    #
    # @param [Array] invalid_sides
    #   the invalid side names
    #
    # @raise [Slideck::InvalidArgumentError]
    #
    # @return [void]
    #
    # @api private
    def self.raise_invalid_margin_as_hash_error(invalid_sides)
      raise InvalidArgumentError,
            "unknown name#{"s" if invalid_sides.size > 1} for margin: " \
            "#{invalid_sides.map(&:inspect).join(", ")}.\n" \
            "Valid names are: top, left, right and bottom."
    end
    private_class_method :raise_invalid_margin_as_hash_error

    # The bottom margin
    #
    # @example
    #   margin.bottom
    #
    # @return [Integer]
    #
    # @api public
    attr_reader :bottom

    # The left margin
    #
    # @example
    #   margin.left
    #
    # @return [Integer]
    #
    # @api public
    attr_reader :left

    # The right margin
    #
    # @example
    #   margin.right
    #
    # @return [Integer]
    #
    # @api public
    attr_reader :right

    # The top margin
    #
    # @example
    #   margin.top
    #
    # @return [Integer]
    #
    # @api public
    attr_reader :top

    # Create a Margin instance
    #
    # @param [Integer] top
    #   the top margin
    # @param [Integer] right
    #   the right margin
    # @param [Integer] bottom
    #   the bottom margin
    # @param [Integer] left
    #   the left margin
    #
    # @api private
    def initialize(top, right, bottom, left)
      @top = validate_margin_side(:top, top)
      @right = validate_margin_side(:right, right)
      @bottom = validate_margin_side(:bottom, bottom)
      @left = validate_margin_side(:left, left)

      freeze
    end
    private_class_method :new

    # Determine equivalence with another object
    #
    # @example
    #   margin == other
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
        top == other.top && right == other.right &&
        bottom == other.bottom && left == other.left
    end

    # Determine for equality with another object
    #
    # @example
    #   margin.eql?(other)
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
        top.eql?(other.top) && right.eql?(other.right) &&
        bottom.eql?(other.bottom) && left.eql?(other.left)
    end

    # Generate hash value of this margin
    #
    # @example
    #   margin.hash
    #
    # @return [Integer]
    #
    # @api public
    def hash
      [self.class, top, right, bottom, left].hash
    end

    # An array representation of all margin sides
    #
    # @example
    #   margin = Slideck::Margin[1, 2, 3, 4]
    #   margin.to_a # => [1, 2, 3, 4]
    #
    # @return [Array<Integer, Integer, Integer, Integer>]
    #
    # @api public
    def to_a
      [top, right, bottom, left]
    end

    private

    # Validate margin side
    #
    # @param [Symbol] side
    #   the margin side
    # @param [Object] value
    #   the value to validate
    #
    # @raise [Slideck::InvalidArgumentError]
    #
    # @return [Integer]
    #
    # @api private
    def validate_margin_side(side, value)
      return value if value.is_a?(Integer)

      raise InvalidArgumentError,
            "#{side} margin needs to be an integer, got: #{value.inspect}"
    end
  end # Margin
end # Slideck
