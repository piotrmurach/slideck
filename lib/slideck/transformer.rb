# frozen_string_literal: true

module Slideck
  # Responsible for transforming file content into metadata and slides
  #
  # @api private
  class Transformer
    # Create a Transformer instance
    #
    # @example
    #   Transformer.new(loader, parser, metadata_wrapper)
    #
    # @param [Slideck::Loader] loader
    #   the file loader
    # @param [Slideck::Parser] parser
    #   the file content parser
    # @param [Slideck::MetadataWrapper] metadata_wrapper
    #   the metadata wrapper
    #
    # @api public
    def initialize(loader, parser, metadata_wrapper)
      @loader = loader
      @parser = parser
      @metadata_wrapper = metadata_wrapper
    end

    # Read metadata and slides from a file
    #
    # @example
    #   transformer.read("slides.md")
    #
    # @param [String] filename
    #   the filename to read metadata and slides from
    #
    # @return [Array<Slideck::Metadata, Array<Hash>>]
    #
    # @api public
    def read(filename)
      @metadata_wrapper.wrap(@parser.parse(@loader.load(filename)))
    end
  end # Transformer
end # Slideck
