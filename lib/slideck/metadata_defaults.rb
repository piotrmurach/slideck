# frozen_string_literal: true

module Slideck
  # Default metadata configuration
  #
  # @api private
  class MetadataDefaults
    # Create a MetadataDefaults instance
    #
    # @example
    #   Slideck::MetadataDefaults.new(Slideck::Alignment)
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
      @defaults = create_defaults
    end

    # Merge given custom metadata with defaults
    #
    # @example
    #   metadata_defaults.merge({align: "center"})
    #
    # @param [Hash{Symbol => Object}] custom_metadata
    #   the custom metadata to merge
    #
    # @return [Hash{Symbol => Object}]
    #
    # @api public
    def merge(custom_metadata)
      @defaults.merge(custom_metadata) do |_, def_val, val|
        def_val.is_a?(::Hash) ? def_val.merge(val) : val
      end
    end

    private

    # The default metadata configuration
    #
    # @return [Hash{Symbol => Object}]
    #
    # @api private
    def create_defaults
      {
        align: @alignment["left", "top"],
        footer: default_footer,
        margin: @margin[0, 0, 0, 0],
        pager: default_pager
      }.freeze
    end

    # The default footer configuration
    #
    # @return [Hash{Symbol => Slideck::Alignment,String}]
    #
    # @api private
    def default_footer
      {
        align: @alignment["left", "bottom"],
        text: ""
      }.freeze
    end

    # The default pager configuration
    #
    # @return [Hash{Symbol => Slideck::Alignment,String}]
    #
    # @api private
    def default_pager
      {
        align: @alignment["right", "bottom"],
        text: "%<page>d / %<total>d"
      }.freeze
    end
  end # MetadataDefaults
end # Slideck
