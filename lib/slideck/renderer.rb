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
    # @param [Slideck::Metadata] metadata
    #   the configuration metadata
    # @param [Integer] width
    #   the screen width
    # @param [Integer] height
    #   the screen height
    #
    # @api public
    def initialize(converter, ansi, cursor, metadata, width: nil, height: nil)
      @converter = converter
      @ansi = ansi
      @cursor = cursor
      @metadata = metadata
      @width = width
      @height = height
    end

    # Render a slide
    #
    # @example
    #   renderer.render("slide content", 1, 5)
    #
    # @param [String, nil] slide
    #   the current slide to render
    # @param [Integer] current_num
    #   the current slide number
    # @param [Integer] num_of_slides
    #   the number of slides
    #
    # @return [String]
    #
    # @api public
    def render(slide, current_num, num_of_slides)
      [].tap do |out|
        out << render_content(slide) if slide
        out << render_footer if @metadata.footer?
        out << render_pager(current_num, num_of_slides) if @metadata.pager?
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
    # @param [String] slide
    #   the slide to render
    #
    # @return [String]
    #
    # @api private
    def render_content(slide)
      converted = convert_markdown(slide)
      render_section(converted.lines, @metadata.align)
    end

    # Render footer
    #
    # @return [String]
    #
    # @api private
    def render_footer
      alignment = @metadata.footer[:align]
      text = @metadata.footer[:text]
      converted = convert_markdown(text).chomp

      render_section(converted.lines, alignment)
    end

    # Render pager
    #
    # @param [Integer] current_num
    #   the current slide number
    # @param [Integer] num_of_slides
    #   the number of slides
    #
    # @return [String]
    #
    # @api private
    def render_pager(current_num, num_of_slides)
      alignment = @metadata.pager[:align]
      text = @metadata.pager[:text]
      formatted_text = format(text, page: current_num, total: num_of_slides)
      converted = convert_markdown(formatted_text).chomp

      render_section(converted.lines, alignment)
    end

    # Render section with aligned lines
    #
    # @param [Array<String>] lines
    #   the lines to align
    # @param [Slideck::Alignment] alignment
    #   the section alignment
    #
    # @return [String]
    #
    # @api private
    def render_section(lines, alignment)
      max_line = max_line_length(lines)
      left = find_left_column(alignment.horizontal, max_line)
      top = find_top_row(alignment.vertical, lines.size)

      lines.map.with_index do |line, i|
        cursor.move_to(left, top + i) + line
      end.join
    end

    # Find a left column
    #
    # @param [String] alignment
    #   the horizontal alignment
    # @param [Integer] content_length
    #   the maximum content length
    #
    # @return [Integer]
    #
    # @api private
    def find_left_column(alignment, content_length)
      case alignment
      when "left"
        0
      when "center"
        (@width - content_length) / 2
      when "right"
        @width - content_length
      end
    end

    # Find a top row
    #
    # @param [String] alignment
    #   the vertical alignment
    # @param [Integer] num_of_lines
    #   the number of content lines
    #
    # @return [Integer]
    #
    # @api private
    def find_top_row(alignment, num_of_lines)
      case alignment
      when "top"
        0
      when "center"
        (@height - num_of_lines) / 2
      when "bottom"
        @height - num_of_lines
      end
    end

    # Convert markdown content to terminal output
    #
    # @param [String] content
    #   the content to convert to terminal output
    #
    # @return [String]
    #
    # @api private
    def convert_markdown(content)
      @converter.convert(content)
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
  end # Renderer
end # Slideck
