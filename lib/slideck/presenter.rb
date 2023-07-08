# frozen_string_literal: true

module Slideck
  # Responsible for presenting slides
  #
  # @api private
  class Presenter
    # Terminal screen size change signal
    #
    # @return [String]
    #
    # @api private
    TERM_SCREEN_SIZE_CHANGE_SIG = "WINCH"
    private_constant :TERM_SCREEN_SIZE_CHANGE_SIG

    # Create a Presenter
    #
    # @param [TTY::Reader] reader
    #   the keyboard input reader
    # @param [Slideck::Renderer] renderer
    #   the slides renderer
    # @param [Slideck::Tracker] tracker
    #   the tracker for slides
    # @param [TTY::Screen] screen
    #   the terminal screen size
    # @param [IO] output
    #   the output stream for the slides
    # @param [Proc] reloader
    #   the metadata and slides reloader
    #
    # @api public
    def initialize(reader, renderer, tracker, screen, output, &reloader)
      @reader = reader
      @renderer = renderer
      @tracker = tracker
      @screen = screen
      @output = output
      @reloader = reloader
      @stop = false
      @buffer = []
    end

    # Reload presentation
    #
    # @example
    #   presenter.reload
    #
    # @return [Slideck::Presenter]
    #
    # @api public
    def reload
      @metadata, @slides = *@reloader.()
      @tracker = @tracker.resize(@slides.size)
      self
    end

    # Start presentation
    #
    # @example
    #   presenter.start
    #
    # @return [void]
    #
    # @api public
    def start
      reload
      @reader.subscribe(self)
      hide_cursor
      subscribe_to_screen_resize { resize.render }

      until @stop
        render
        @reader.read_keypress
      end
    ensure
      show_cursor
    end

    # Stop presentation
    #
    # @example
    #   presenter.stop
    #
    # @return [Slideck::Presenter]
    #
    # @api public
    def stop
      @stop = true
      self
    end

    # Render presentation on cleared screen
    #
    # @example
    #   presenter.render
    #
    # @return [void]
    #
    # @api public
    def render
      clear_screen
      render_slide
    end

    # Clear terminal screen
    #
    # @return [void]
    #
    # @api private
    def clear_screen
      @output.print @renderer.clear
    end

    # Render the current slide
    #
    # @return [void]
    #
    # @api private
    def render_slide
      @output.print @renderer.render(
        @metadata,
        @slides[@tracker.current],
        @tracker.current + 1,
        @tracker.total)
    end

    # Hide cursor
    #
    # @return [void]
    #
    # @api private
    def hide_cursor
      @output.print @renderer.cursor.hide
    end

    # Show cursor
    #
    # @return [void]
    #
    # @api private
    def show_cursor
      @output.print @renderer.cursor.show
    end

    # Subscribe to the terminal screen size change signal
    #
    # @param [Proc] resizer
    #   the presentation resizer
    #
    # @return [void]
    #
    # @api private
    def subscribe_to_screen_resize(&resizer)
      return if @screen.windows?

      Signal.trap(TERM_SCREEN_SIZE_CHANGE_SIG, &resizer)
    end

    # Resize presentation
    #
    # @return [Slideck::Presenter]
    #
    # @api private
    def resize
      @renderer = @renderer.resize(@screen.width, @screen.height)
      self
    end

    # Handle a keypress event
    #
    # @param [TTY::Reader::KeyEvent] event
    #   the key event
    #
    # @return [void]
    #
    # @api private
    def keypress(event)
      case event.value
      when "n", "l" then keyright
      when "p", "h" then keyleft
      when "^" then go_to_first
      when "$" then go_to_last
      when "g" then go_to_slide
      when /\d/ then add_to_buffer(event.value)
      when "r" then keyctrl_l
      when "q" then keyctrl_x
      end
    end

    # Navigate to the next slide
    #
    # @return [void]
    #
    # @api private
    def keyright(*)
      @tracker = @tracker.next
    end
    alias keyspace keyright
    alias keypage_down keyright

    # Navigate to the previous slide
    #
    # @return [void]
    #
    # @api private
    def keyleft(*)
      @tracker = @tracker.previous
    end
    alias keybackspace keyleft
    alias keypage_up keyleft

    # Reload presentation
    #
    # @return [void]
    #
    # @api private
    def keyctrl_l(*)
      reload
    end

    # Exit presentation
    #
    # @return [void]
    #
    # @api private
    def keyctrl_x(*)
      clear_screen
      stop
    end
    alias keyescape keyctrl_x

    # Navigate to the fist slide
    #
    # @return [void]
    #
    # @api private
    def go_to_first
      @tracker = @tracker.first
    end

    # Navigate to the last slide
    #
    # @return [void]
    #
    # @api private
    def go_to_last
      @tracker = @tracker.last
    end

    # Navigate to a given slide
    #
    # @return [void]
    #
    # @api private
    def go_to_slide
      @tracker = @tracker.go_to(@buffer.join.to_i - 1)
      @buffer.clear
    end

    # Add to the input buffer
    #
    # @param [String] input_key
    #   the input key
    #
    # @return [void]
    #
    # @api private
    def add_to_buffer(input_key)
      @buffer += [input_key]
    end
  end # Presenter
end # Slideck
