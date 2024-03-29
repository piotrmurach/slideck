# frozen_string_literal: true

module Slideck
  # Responsible for rendering slides
  #
  # @api private
  class Renderer
    # The terminal cursor
    #
    # @example
    #   renderer.cursor
    #
    # @return [TTY::Cursor]
    #
    # @api public
    attr_reader :cursor

    # Create a Renderer instance
    #
    # @param [Slideck::Converter] converter
    #   the markdown to terminal output converter
    # @param [Strings::ANSI] ansi
    #   the ansi codes handler
    # @param [TTY::Cursor] cursor
    #   the cursor navigation
    # @param [Integer] width
    #   the screen width
    # @param [Integer] height
    #   the screen height
    #
    # @api public
    def initialize(converter, ansi, cursor, width: nil, height: nil)
      @converter = converter
      @ansi = ansi
      @cursor = cursor
      @width = width
      @height = height

      freeze
    end

    # Create a Renderer with a new screen size
    #
    # @example
    #   renderer.resize(200, 50)
    #
    # @param [Integer] width
    #   the screen width
    # @param [Integer] height
    #   the screen height
    #
    # @return [Slideck::Renderer]
    #
    # @api public
    def resize(width, height)
      self.class.new(@converter, @ansi, @cursor, width: width, height: height)
    end

    # Render a slide
    #
    # @example
    #   renderer.render(metadata, slide, 1, 5)
    #
    # @param [Slideck::Metadata] metadata
    #   the global metadata
    # @param [Hash{Symbol => Hash, String}, nil] slide
    #   the current slide to render
    # @param [Integer] current_num
    #   the current slide number
    # @param [Integer] num_of_slides
    #   the number of slides
    #
    # @return [String]
    #
    # @api public
    def render(metadata, slide, current_num, num_of_slides)
      slide_metadata = slide && slide[:metadata]
      [].tap do |out|
        out << render_content(metadata, slide) if slide
        out << render_footer(metadata, slide_metadata)
        out << render_pager(metadata, slide_metadata,
                            current_num, num_of_slides)
      end.join
    end

    # Clear terminal screen
    #
    # @example
    #   renderer.clear
    #
    # @return [String]
    #
    # @api public
    def clear
      cursor.clear_screen + cursor.move_to(0, 0)
    end

    private

    # Render slide content
    #
    # @param [Slideck::Metadata] metadata
    #   the global metadata
    # @param [Hash{Symbol => Hash, String}] slide
    #   the slide to render
    #
    # @return [String]
    #
    # @api private
    def render_content(metadata, slide)
      alignment, margin, symbols, theme =
        *select_metadata(metadata, slide[:metadata], :align, :margin,
                         :symbols, :theme)
      converted = convert_markdown(slide[:content], margin, symbols, theme)

      render_section(converted.lines, alignment, margin)
    end

    # Render footer
    #
    # @param [Slideck::Metadata] metadata
    #   the global metadata
    # @param [Slideck::Metadata] slide_metadata
    #   the slide metadata
    #
    # @return [String]
    #
    # @api private
    def render_footer(metadata, slide_metadata)
      footer_metadata = pick_metadata(metadata, slide_metadata, :footer)
      return if (text = footer_metadata[:text]).empty?

      alignment = footer_metadata[:align] || metadata.footer[:align]
      margin, symbols, theme =
        *select_metadata(metadata, slide_metadata, :margin, :symbols, :theme)
      converted = convert_markdown(text, margin, symbols, theme).chomp

      render_section(converted.lines, alignment, margin)
    end

    # Render pager
    #
    # @param [Slideck::Metadata] metadata
    #   the global metadata
    # @param [Slideck::Metadata] slide_metadata
    #   the slide metadata
    # @param [Integer] current_num
    #   the current slide number
    # @param [Integer] num_of_slides
    #   the number of slides
    #
    # @return [String]
    #
    # @api private
    def render_pager(metadata, slide_metadata, current_num, num_of_slides)
      pager_metadata = pick_metadata(metadata, slide_metadata, :pager)
      return if (text = pager_metadata[:text]).empty?

      alignment = pager_metadata[:align] || metadata.pager[:align]
      margin, symbols, theme =
        *select_metadata(metadata, slide_metadata, :margin, :symbols, :theme)
      formatted_text = format(text, page: current_num, total: num_of_slides)
      converted = convert_markdown(formatted_text, margin, symbols, theme).chomp

      render_section(converted.lines, alignment, margin)
    end

    # Select configuration(s) by name(s) from metadata
    #
    # @param [Slideck::Metadata] metadata
    #   the global metadata
    # @param [Slideck::Metadata] slide_metadata
    #   the slide metadata
    # @param [Array<Symbol>] names
    #   the configuration names
    #
    # @return [Array<Object>]
    #
    # @api private
    def select_metadata(metadata, slide_metadata, *names)
      names.each_with_object([]) do |name, selected|
        selected << pick_metadata(metadata, slide_metadata, name)
      end
    end

    # Pick configuration by name from metadata
    #
    # @param [Slideck::Metadata] metadata
    #   the global metadata
    # @param [Slideck::Metadata] slide_metadata
    #   the slide metadata
    # @param [Symbol] name
    #   the configuration name
    #
    # @return [Hash, Slideck::Alignment, Slideck::Margin, String, Symbol]
    #
    # @api private
    def pick_metadata(metadata, slide_metadata, name)
      slide_metadata_item = slide_metadata && slide_metadata.send(name)
      slide_metadata_item || metadata.send(name)
    end

    # Render section with aligned lines
    #
    # @param [Array<String>] lines
    #   the lines to align
    # @param [Slideck::Alignment] alignment
    #   the section alignment
    # @param [Slideck::Margin] margin
    #   the slide margin
    #
    # @return [String]
    #
    # @api private
    def render_section(lines, alignment, margin)
      max_line = max_line_length(lines)
      left = find_left_column(alignment.horizontal, margin, max_line)
      top = find_top_row(alignment.vertical, margin, lines.size)

      lines.map.with_index do |line, i|
        cursor.move_to(left, top + i) + line
      end.join
    end

    # Find a left column
    #
    # @param [String] alignment
    #   the horizontal alignment
    # @param [Slideck::Margin] margin
    #   the slide margin
    # @param [Integer] content_length
    #   the maximum content length
    #
    # @return [Integer]
    #
    # @api private
    def find_left_column(alignment, margin, content_length)
      case alignment
      when "left"
        margin.left
      when "center"
        margin.left + ((slide_width(margin) - content_length) / 2)
      when "right"
        margin.left + (slide_width(margin) - content_length)
      end
    end

    # Find a top row
    #
    # @param [String] alignment
    #   the vertical alignment
    # @param [Slideck::Margin] margin
    #   the slide margin
    # @param [Integer] num_of_lines
    #   the number of content lines
    #
    # @return [Integer]
    #
    # @api private
    def find_top_row(alignment, margin, num_of_lines)
      case alignment
      when "top"
        margin.top
      when "center"
        margin.top + ((slide_height(margin) - num_of_lines) / 2)
      when "bottom"
        margin.top + (slide_height(margin) - num_of_lines)
      end
    end

    # Convert markdown content to terminal output
    #
    # @param [String] content
    #   the content to convert to terminal output
    # @param [Slideck::Margin] margin
    #   the slide margin
    # @param [Hash, String, Symbol] symbols
    #   the converted content symbols
    # @param [Hash{Symbol => Array, String, Symbol}] theme
    #   the converted content theme
    #
    # @return [String]
    #
    # @api private
    def convert_markdown(content, margin, symbols, theme)
      @converter.convert(
        content, symbols: symbols, theme: theme, width: slide_width(margin))
    end

    # Find maximum line length
    #
    # @param [Array<String>] lines
    #   the lines to search through
    #
    # @return [Integer]
    #
    # @api private
    def max_line_length(lines)
      lines.map { |line| @ansi.sanitize(line).size }.max
    end

    # Calculate slide height
    #
    # @param [Slideck::Margin] margin
    #   the slide margin
    #
    # @return [Integer]
    #
    # @api private
    def slide_height(margin)
      @height - margin.top - margin.bottom
    end

    # Calculate slide width
    #
    # @param [Slideck::Margin] margin
    #   the slide margin
    #
    # @return [Integer]
    #
    # @api private
    def slide_width(margin)
      @width - margin.left - margin.right
    end
  end # Renderer
end # Slideck
