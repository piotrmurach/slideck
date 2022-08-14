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

    # The pager configuration
    #
    # @return [Hash{Symbol => Slideck::Alignment,String}]
    define_meta :pager

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

    # Whether the footer is configured or not
    #
    # @example
    #   metadata.footer?
    #
    # @return [Boolean]
    #   true if footer is configured, false otherwise
    #
    # @api public
    def footer?
      !footer[:text].empty?
    end

    # Whether the pager is configured or not
    #
    # @example
    #   metadata.pager?
    #
    # @return [Boolean]
    #   true if pager is configured, false otherwise
    #
    # @api public
    def pager?
      !pager[:text].empty?
    end
  end # Metadata
end # Slideck
