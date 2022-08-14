# frozen_string_literal: true

module Slideck
  # Responsible for extracting metadata and slides from content
  #
  # @api private
  class Parser
    # The pattern to detect metadata configuration
    #
    # @return [Regexp]
    #
    # @api private
    METADATA_PATTERN = /^[^:]+:[^:]+$/.freeze
    private_constant :METADATA_PATTERN

    # The pattern to detect slide separator
    #
    # @return [Regexp]
    #
    # @api private
    SLIDE_SEPARATOR = /\n?-{3,}\n/.freeze
    private_constant :SLIDE_SEPARATOR

    # The pattern to match entire lines
    #
    # @return [Regexp]
    #
    # @api private
    LINE_PATTERN = /^[^\n]+$/.freeze
    private_constant :LINE_PATTERN

    # Create a Parser instance
    #
    # @example
    #   Parser.new(StringScanner, YAML, {})
    #
    # @param [StringScanner] string_scanner
    #   the content scanner
    # @param [YAML] metadata_parser
    #   the metadata parser
    # @param [Hash{Symbol => Object}] parser_settings
    #   the metadata parser settings
    #
    # @api public
    def initialize(string_scanner, metadata_parser, parser_settings)
      @string_scanner = string_scanner
      @metadata_parser = metadata_parser
      @parser_settings = parser_settings
    end

    # Parse metadata and slides from content
    #
    # @example
    #   Parser.parse("align: center\n---\nSlide1\n---\nSlide2\n---")
    #
    # @param [String] content
    #   the content to parse slides from
    #
    # @return [Hash{Symbol => Hash,Array<String>}]
    #   the metadata and slides content
    #
    # @api public
    def parse(content)
      scanner = @string_scanner.new(content)
      slides = split_into_slides(scanner)
      metadata = extract_metadata(slides.first)

      {metadata: metadata, slides: metadata.empty? ? slides : slides[1..-1]}
    end

    private

    # Split content into slides
    #
    # @param [StringScanner] scanner
    #   the slides content scanner
    #
    # @return [Array<String>]
    #
    # @api private
    def split_into_slides(scanner)
      slides, slide = [], []

      until scanner.eos?
        if scanner.scan(SLIDE_SEPARATOR)
          slides = add_slide(slides, slide.join)
          slide.clear
        elsif scanner.scan(LINE_PATTERN)
          slide << scanner.matched
        else
          slide << scanner.getch
        end
      end

      add_slide(slides, slide.join.chomp)
    end

    # Add a slide to slides
    #
    # @param [Array<String>] slides
    #   the slides array
    # @param [String] slide
    #   the slide to add to slides
    #
    # @return [Array<String>]
    #
    # @api private
    def add_slide(slides, slide)
      return slides if slide.empty?

      slides + [slide]
    end

    # Extract metadata from a slide
    #
    # @param [String, nil] slide
    #
    # @return [Hash]
    #
    # @api private
    def extract_metadata(slide)
      return {} if slide.nil? || !metadata_given?(slide)

      parse_metadata(slide)
    end

    # Check whether or not metadata is given
    #
    # @param [String] content
    #   the slide content to check
    #
    # @return [Boolean]
    #
    # @api private
    def metadata_given?(content)
      !(content.lines.first =~ METADATA_PATTERN).nil?
    end

    # Parse metadata content into a hash
    #
    # @param [String] content
    #   the metadata content to parse
    #
    # @return [Hash{Symbol => Object}]
    #
    # @api private
    def parse_metadata(content)
      @metadata_parser.send(parse_method, content, **@parser_settings)
    end

    # Select a metadata parse method
    #
    # @return [Symbol]
    #
    # @api private
    def parse_method
      @metadata_parser.respond_to?(:safe_load) ? :safe_load : :load
    end
  end # Parser
end # Slideck
