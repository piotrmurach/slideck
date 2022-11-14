# frozen_string_literal: true

module Slideck
  # Responsible for converting custom metadata
  #
  # @api private
  class MetadataConverter
    # Create a MetadataConverter instance
    #
    # @example
    #   Slideck::MetadataConverter.new(Slideck::Alignment)
    #
    # @param [Slideck::Alignment] alignment
    #   the alignment initialiser
    # @param [Slideck::Margin] margin
    #   the margin initialiser
    #
    # @api public
    def initialize(alignment, margin)
      @alignment = alignment
      @margin = margin
    end

    # Convert metadata values
    #
    # @example
    #   metadata_converter.convert({align: "center"})
    #
    # @param [Hash{Symbol => Object}] custom_metadata
    #   the custom metadata to convert
    #
    # @return [Hash{Symbol => Object}]
    #
    # @api public
    def convert(custom_metadata)
      custom_metadata.each_with_object({}) do |(key, val), new_metadata|
        new_metadata[key] = convert_for(key, val)
      end
    end

    private

    # Convert a value for a metadata key
    #
    # @param [Symbol] key
    #   the metadata key
    # @param [Object] value
    #   the metadata value
    #
    # @return [Hash, Slideck::Alignment, Slideck::Margin]
    #
    # @api private
    def convert_for(key, value)
      case key
      when :align
        @alignment.from(value)
      when :margin
        @margin.from(value)
      when :footer, :pager
        convert_align_key(wrap_with_text_key(value), "bottom")
      end
    end

    # Wrap value in Hash with text key
    #
    # @param [Hash, String] value
    #   the value to wrap with text key
    #
    # @return [Hash{Symbol => String}]
    #
    # @api private
    def wrap_with_text_key(value)
      value.is_a?(::Hash) ? value : {text: value || ""}
    end

    # Convert value for align key in Hash to Alignment
    #
    # @param [Hash] value
    #   the value with align key
    # @param [String] default
    #   the default vertical alignment
    #
    # @return [Hash{Symbol => Slideck::Alignment,String}]
    #
    # @api private
    def convert_align_key(value, default)
      return value unless value.key?(:align)

      alignment = @alignment.from(value[:align], default: default)
      value.merge(align: alignment)
    end
  end # MetadataConverter
end # Slideck
