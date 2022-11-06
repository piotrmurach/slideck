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
    METADATA_PATTERN = /^\s*:?[^:]+:[^:]+/.freeze
    private_constant :METADATA_PATTERN

    # The pattern to detect slide separator
    #
    # @return [Regexp]
    #
    # @api private
    SLIDE_SEPARATOR = /\n?-{3,}([^\n]*)\n/.freeze
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
    #   Parser.new(StringScanner, Slideck::MetadataParser)
    #
    # @param [StringScanner] string_scanner
    #   the content scanner
    # @param [Slideck::MetadataParser] metadata_parser
    #   the metadata parser
    #
    # @api public
    def initialize(string_scanner, metadata_parser)
      @string_scanner = string_scanner
      @metadata_parser = metadata_parser
    end

    # Parse metadata and slides from content
    #
    # @example
    #   parser.parse("align: center\n---\nSlide1\n---\nSlide2\n---")
    #
    # @param [String] content
    #   the content to parse slides from
    #
    # @return [Hash{Symbol => Hash, Array<String>}]
    #   the metadata and slides content
    #
    # @api public
    def parse(content)
      scanner = @string_scanner.new(content)
      slides = split_into_slides(scanner)
      metadata = extract_metadata(slides.first && slides.first[:content])

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
      slides, slide, slide_metadata = [], [], {}

      until scanner.eos?
        if scanner.scan(SLIDE_SEPARATOR)
          slides = add_slide(slides, slide.join, slide_metadata)
          slide_metadata = extract_metadata(scanner[1])
          slide.clear
        elsif scanner.scan(LINE_PATTERN)
          slide << scanner.matched
        else
          slide << scanner.getch
        end
      end

      add_slide(slides, slide.join.chomp, slide_metadata)
    end

    # Add a slide to slides
    #
    # @param [Array<String>] slides
    #   the slides array
    # @param [String] slide
    #   the slide to add to slides
    # @param [Hash{String, Symbol => Object}] slide_metadata
    #   the slide metadata
    #
    # @return [Array<Hash{Symbol => Hash, String}>]
    #
    # @api private
    def add_slide(slides, slide, slide_metadata)
      return slides if slide.empty?

      slides + [{content: slide, metadata: slide_metadata}]
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

      @metadata_parser.parse(slide)
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
  end # Parser
end # Slideck
