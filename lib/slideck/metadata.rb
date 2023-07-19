# frozen_string_literal: true

module Slideck
  # Responsible for accessing metadata configuration
  #
  # @api private
  class Metadata
    # Create a Metadata instance from slides configuration
    #
    # @param [Slideck::MetadataConverter] metadata_converter
    #   the metadata converter
    # @param [Hash{Symbol => Object}] custom_metadata
    #   the custom metadata
    # @param [MetadataDefaults] metadata_defaults
    #   the metadata defaults
    #
    # @raise [Slideck::InvalidMetadataKeyError]
    #
    # @return [Slideck::Metadata]
    #
    # @api public
    def self.from(metadata_converter, custom_metadata, metadata_defaults)
      validate_keys(custom_metadata.keys)

      new(metadata_defaults.merge(metadata_converter.convert(custom_metadata)))
    end

    # Check for unknown metadata keys
    #
    # @param [Array<Symbol>] custom_metadata_keys
    #   the custom metadata keys
    #
    # @raise [Slideck::InvalidMetadataKeyError]
    #
    # @return [nil]
    #
    # @api private
    def self.validate_keys(custom_metadata_keys)
      unknown_keys = custom_metadata_keys - @metadata_keys
      return if unknown_keys.empty?

      raise InvalidMetadataKeyError.new(@metadata_keys, unknown_keys)
    end
    private_class_method :validate_keys

    # Define a method to access metadata
    #
    # @param [Symbol] key
    #   the metadata key name
    #
    # @return [void]
    #
    # @api private
    def self.define_meta(key)
      define_method(key) { @metadata[key] }
      (@metadata_keys ||= []) << key
    end
    private_class_method :define_meta

    # The alignment configuration
    #
    # @return [Slideck::Alignment]
    define_meta :align

    # The footer configuration
    #
    # @return [Hash{Symbol => Slideck::Alignment,String}]
    define_meta :footer

    # The margin configuration
    #
    # @return [Slideck::Margin]
    define_meta :margin

    # The pager configuration
    #
    # @return [Hash{Symbol => Slideck::Alignment,String}]
    define_meta :pager

    # The symbols configuration
    #
    # @return [Hash, String, Symbol]
    define_meta :symbols

    # The theme configuration
    #
    # @return [Hash{Symbol => Array, String, Symbol}]
    define_meta :theme

    # Create a Metadata instance
    #
    # @param [Hash{Symbol => Object}] metadata
    #   the metadata configuration
    #
    # @api private
    def initialize(metadata)
      @metadata = metadata

      freeze
    end
    private_class_method :new

    # Determine equivalence with another object
    #
    # @example
    #   metadata == other
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
        @metadata.keys.all? do |name|
          send(name) == other.send(name)
        end
    end

    # Determine equality with another object
    #
    # @example
    #   metadata.eql?(other)
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
        @metadata.keys.all? do |name|
          send(name).eql?(other.send(name))
        end
    end

    # Generate hash value of this metadata
    #
    # @example
    #   metadata.hash
    #
    # @return [Integer]
    #
    # @api public
    def hash
      [self.class, *@metadata.keys.map { |name| send(name) }].hash
    end
  end # Metadata
end # Slideck
