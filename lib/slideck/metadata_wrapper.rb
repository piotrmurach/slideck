# frozen_string_literal: true

module Slideck
  # Responsible for wrapping parsed global and slide metadata
  #
  # @api private
  class MetadataWrapper
    # Create a MetadataWrapper instance
    #
    # @example
    #   MetadataWrapper.new(metadata, metadata_converter, metadata_defaults)
    #
    # @param [Slideck::Metadata] metadata
    #   the metadata initialiser
    # @param [Slideck::MetadataConverter] metadata_converter
    #   the metadata converter
    # @param [Slideck::MetadataDefaults] metadata_defaults
    #   the metadata defaults
    #
    # @api public
    def initialize(metadata, metadata_converter, metadata_defaults)
      @metadata = metadata
      @metadata_converter = metadata_converter
      @metadata_defaults = metadata_defaults
    end

    # Wrap parsed global and slide metadata
    #
    # @example
    #   metadata_wrapper.wrap({metadata: {}, slides: []})
    #
    # @param [Hash{Symbol => Hash, String}] deck
    #   the deck of parsed metadata and slides
    #
    # @return [Array<Slideck::Metadata, Hash>]
    #
    # @api public
    def wrap(deck)
      [
        build_metadata(deck[:metadata], @metadata_defaults),
        deck[:slides].map do |slide|
          {
            content: slide[:content],
            metadata: build_metadata(slide[:metadata], {})
          }
        end
      ]
    end

    private

    # Build metadata
    #
    # @param [Hash{Symbol => Object}] custom_metadata
    #   the custom metadata
    # @param [#merge] defaults
    #   the defaults to merge with
    #
    # @return [Slideck::Metadata]
    #
    # @api private
    def build_metadata(custom_metadata, defaults)
      @metadata.from(@metadata_converter, custom_metadata, defaults)
    end
  end # MetadataWrapper
end # Slideck
