# frozen_string_literal: true

module Slideck
  # Responsible for loading slides
  #
  # @api private
  class Loader
    # Create a Loader instance
    #
    # @example
    #   Slideck::Loader.new(File)
    #
    # @param [#read] read_handler
    #   the read handler for slides
    #
    # @api public
    def initialize(read_handler)
      @read_handler = read_handler
    end

    # Load slides from a location
    #
    # @example
    #   loader.load("slides.md")
    #
    # @param [String] location
    #   the location of the slides to load
    #
    # @raise [Slideck::ReadError]
    #
    # @return [String]
    #   the slides content
    #
    # @api public
    def load(location)
      if location.nil?
        raise ReadError, "the location for the slides must be given"
      end

      @read_handler.read(location)
    rescue SystemCallError => err
      raise ReadError, err.message
    end
  end # Loader
end # Slideck
