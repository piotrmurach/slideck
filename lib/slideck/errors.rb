# frozen_string_literal: true

module Slideck
  # Raised to signal an error condition
  #
  # @api public
  Error = Class.new(StandardError)

  # Raised when unable to read slides from a location
  #
  # @api public
  ReadError = Class.new(Error)

  # Raised when argument is invalid
  #
  # @api public
  InvalidArgumentError = Class.new(Error)

  # Raised when metadata key is invalid
  #
  # @api public
  class InvalidMetadataKeyError < Error
    MESSAGE = "unknown '%<keys>s' configuration %<name>s\n" \
              "Available keys are: %<meta_keys>s"

    # Create an InvalidMetadataKeyError instance
    #
    # @example
    #   metadata_keys = %i[align footer pager]
    #   Slideck::InvalidMetadataKeyError.new(metadata_keys, %i[invalid])
    #
    # @param [Array<Symbol>] metadata_keys
    #   the allowed metadata keys
    # @param [Array<String>] keys
    #   the invalid metadata keys
    #
    # @api public
    def initialize(metadata_keys, keys)
      super(format(MESSAGE,
                   keys: keys.join(", "),
                   name: pluralize("key", keys.size),
                   meta_keys: metadata_keys.map(&:inspect).join(", ")))
    end

    private

    # Pluralize a noun
    #
    # @param [String] noun
    #   the noun to pluralize
    # @param [Integer] count
    #   the count of items
    #
    # @return [String]
    #
    # @api private
    def pluralize(noun, count = 1)
      "#{noun}#{"s" unless count == 1}"
    end
  end # InvalidMetadataKeyError
end # Slideck
