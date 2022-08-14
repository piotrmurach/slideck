# frozen_string_literal: true

module Slideck
  # Responsible for tracking current slide number
  #
  # @api private
  class Tracker
    # Create a Tracker instance with the current slide set to zero
    #
    # @example
    #   Slideck::Tracker.for(11)
    #
    # @param [Integer] total
    #   the total number of slides
    #
    # @return [Slideck::Tracker]
    #
    # @api public
    def self.for(total)
      new(0, total)
    end

    # The current slide number
    #
    # @example
    #   tracker.current
    #
    # @return [Integer]
    #
    # @api public
    attr_reader :current

    # The total number of slides
    #
    # @example
    #   tracker.total
    #
    # @return [Integer]
    #
    # @api public
    attr_reader :total

    # Create a Tracker instance
    #
    # @example
    #   Slideck::Tracker.new(0, 11)
    #
    # @param [Integer] current
    #   the current slide number
    # @param [Integer] total
    #   the total number of slides
    #
    # @api public
    def initialize(current, total)
      @current = current
      @total = total

      freeze
    end

    # Move to the next slide
    #
    # @example
    #   tracker = tracker.next
    #
    # @return [Slideck::Tracker]
    #
    # @api public
    def next
      return self if current >= total - 1

      self.class.new(current + 1, total)
    end

    # Move to the previous slide
    #
    # @example
    #   tracker = tracker.previous
    #
    # @return [Slideck::Tracker]
    #
    # @api public
    def previous
      return self if current.zero?

      self.class.new(current - 1, total)
    end

    # Move to the first slide
    #
    # @example
    #   tracker = tracker.first
    #
    # @return [Slideck::Tracker]
    #
    # @api public
    def first
      self.class.new(0, total)
    end

    # Move to the last slide
    #
    # @example
    #   tracker = tracker.last
    #
    # @return [Slideck::Tracker]
    #
    # @api public
    def last
      self.class.new(total - 1, total)
    end

    # Go to a specific slide number
    #
    # @example
    #   tracker = tracker.go_to(5)
    #
    # @param [Integer] slide_no
    #   the slide number
    #
    # @return [Slideck::Tracker]
    #
    # @api public
    def go_to(slide_no)
      return self if slide_no < 0 || total - 1 < slide_no

      self.class.new(slide_no, total)
    end
  end # Tracker
end # Slideck
