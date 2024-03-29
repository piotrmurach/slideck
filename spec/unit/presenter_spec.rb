# frozen_string_literal: true

RSpec.describe Slideck::Presenter do
  let(:output) { StringIO.new("".dup, "w+") }
  let(:input) { StringIO.new("".dup, "w+") }
  let(:env) { {"TTY_TEST" => true} }
  let(:reader) { TTY::Reader.new(input: input, output: output, env: env) }
  let(:ansi) { Strings::ANSI }
  let(:cursor) { TTY::Cursor }
  let(:markdown) { TTY::Markdown }
  let(:converter) { Slideck::Converter.new(markdown, color: :always) }
  let(:alignment) { Slideck::Alignment }
  let(:margin) { Slideck::Margin }
  let(:meta_converter) { Slideck::MetadataConverter.new(alignment, margin) }
  let(:meta_defaults) { Slideck::MetadataDefaults.new(alignment, margin) }
  let(:metadata) { Slideck::Metadata.from(meta_converter, {}, meta_defaults) }
  let(:slide_metadata) { Slideck::Metadata.from(meta_converter, {}, {}) }
  let(:windows?) { RSpec::Support::OS.windows? }
  let(:screen_methods) { {width: 20, height: 8, windows?: windows?} }
  let(:screen) { class_double(TTY::Screen, **screen_methods) }

  def build_metadata(custom_metadata)
    Slideck::Metadata.from(meta_converter, custom_metadata, meta_defaults)
  end

  describe "#reload" do
    it "reloads the presentation with new metadata and slides" do
      slides = Array.new(5) do |i|
        {content: "slide#{i + 1}", metadata: slide_metadata}
      end
      tracker = Slideck::Tracker.for(slides.size)
      renderer = Slideck::Renderer.new(
        converter, ansi, cursor, width: screen.width, height: screen.height)
      reloaded_metadata = build_metadata({theme: {strong: :cyan}})
      reloaded_slides = [{content: "**Reloaded**", metadata: slide_metadata}]
      presenter = described_class.new(
        reader, renderer, tracker, screen, output) do
        [reloaded_metadata, reloaded_slides]
      end

      presenter.reload.render

      expect(output.string.inspect).to eq([
        "\e[2J\e[1;1H",
        "\e[1;1H\e[36mReloaded\e[0m\n",
        "\e[8;16H1 / 1"
      ].join.inspect)
    end
  end

  describe "#start" do
    it "quits slides immediately with 'q' key" do
      slides = [{content: "slide1", metadata: slide_metadata},
                {content: "slide2", metadata: slide_metadata},
                {content: "slide3", metadata: slide_metadata}]
      tracker = Slideck::Tracker.for(slides.size)
      renderer = Slideck::Renderer.new(
        converter, ansi, cursor, width: screen.width, height: screen.height)
      presenter = described_class.new(
        reader, renderer, tracker, screen, output) do
        [metadata, slides]
      end
      input << "q"
      input.rewind

      presenter.start

      expect(output.string.inspect).to eq([
        "\e[?25l\e[2J\e[1;1H",
        "\e[1;1Hslide1\n",
        "\e[8;16H1 / 3",
        "\e[2J\e[1;1H\e[?25h"
      ].join.inspect)
    end

    it "navigates slides with letter keys and quits with Ctrl+X" do
      slides = [{content: "slide1", metadata: slide_metadata},
                {content: "slide2", metadata: slide_metadata},
                {content: "slide3", metadata: slide_metadata}]
      tracker = Slideck::Tracker.for(slides.size)
      renderer = Slideck::Renderer.new(
        converter, ansi, cursor, width: screen.width, height: screen.height)
      presenter = described_class.new(
        reader, renderer, tracker, screen, output) do
        [metadata, slides]
      end
      input << "n" << "l" << "p" << "h" << ?\C-x
      input.rewind

      presenter.start

      expect(output.string.inspect).to eq([
        "\e[?25l\e[2J\e[1;1H",
        "\e[1;1Hslide1\n",
        "\e[8;16H1 / 3",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide2\n",
        "\e[8;16H2 / 3",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide3\n",
        "\e[8;16H3 / 3",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide2\n",
        "\e[8;16H2 / 3",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide1\n",
        "\e[8;16H1 / 3",
        "\e[2J\e[1;1H\e[?25h"
      ].join.inspect)
    end

    it "navigates slides with arrow, page up/down, space and backspace keys" do
      slides = [{content: "slide1", metadata: slide_metadata},
                {content: "slide2", metadata: slide_metadata},
                {content: "slide3", metadata: slide_metadata}]
      tracker = Slideck::Tracker.for(slides.size)
      renderer = Slideck::Renderer.new(
        converter, ansi, cursor, width: screen.width, height: screen.height)
      presenter = described_class.new(
        reader, renderer, tracker, screen, output) do
        [metadata, slides]
      end
      reader.on(:keypress) do |event|
        reader.trigger(:keyleft) if event.value == "a"
        reader.trigger(:keyright) if event.value == "d"
        reader.trigger(:keypage_up) if event.value == "w"
        reader.trigger(:keypage_down) if event.value == "s"
        reader.trigger(:keybackspace) if event.value == "b"
      end
      input << "d" << " " << "a" << "b" << "s" << "w" << "q"
      input.rewind

      presenter.start

      expect(output.string.inspect).to eq([
        "\e[?25l\e[2J\e[1;1H",
        "\e[1;1Hslide1\n",
        "\e[8;16H1 / 3",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide2\n",
        "\e[8;16H2 / 3",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide3\n",
        "\e[8;16H3 / 3",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide2\n",
        "\e[8;16H2 / 3",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide1\n",
        "\e[8;16H1 / 3",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide2\n",
        "\e[8;16H2 / 3",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide1\n",
        "\e[8;16H1 / 3",
        "\e[2J\e[1;1H\e[?25h"
      ].join.inspect)
    end

    it "navigates straight to the last and first slide and quits with Esc" do
      slides = [{content: "slide1", metadata: slide_metadata},
                {content: "slide2", metadata: slide_metadata},
                {content: "slide3", metadata: slide_metadata}]
      tracker = Slideck::Tracker.for(slides.size)
      renderer = Slideck::Renderer.new(
        converter, ansi, cursor, width: screen.width, height: screen.height)
      presenter = described_class.new(
        reader, renderer, tracker, screen, output) do
        [metadata, slides]
      end
      input << "t" << "f" << "$" << "^" << "\e"
      input.rewind

      presenter.start

      expect(output.string.inspect).to eq([
        "\e[?25l\e[2J\e[1;1H",
        "\e[1;1Hslide1\n",
        "\e[8;16H1 / 3",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide3\n",
        "\e[8;16H3 / 3",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide1\n",
        "\e[8;16H1 / 3",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide3\n",
        "\e[8;16H3 / 3",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide1\n",
        "\e[8;16H1 / 3",
        "\e[2J\e[1;1H\e[?25h"
      ].join.inspect)
    end

    it "navigates to a specific slide and exits with Ctrl+C" do
      slides = Array.new(15) do |i|
        {content: "slide#{i + 1}", metadata: slide_metadata}
      end
      tracker = Slideck::Tracker.for(slides.size)
      renderer = Slideck::Renderer.new(
        converter, ansi, cursor, width: screen.width, height: screen.height)
      presenter = described_class.new(
        reader, renderer, tracker, screen, output) do
        [metadata, slides]
      end
      input << "1" << "3" << "g" << "q" << ?\C-c
      input.rewind

      presenter.start

      expect(output.string.inspect).to eq([
        "\e[?25l\e[2J\e[1;1H",
        "\e[1;1Hslide1\n",
        "\e[8;15H1 / 15",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide1\n",
        "\e[8;15H1 / 15",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide1\n",
        "\e[8;15H1 / 15",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide13\n",
        "\e[8;14H13 / 15",
        "\e[2J\e[1;1H\e[?25h"
      ].join.inspect)
    end

    it "reloads slides with the 'r' and Ctrl+L keys and quits" do
      slides = [{content: "slide1", metadata: slide_metadata},
                {content: "slide2", metadata: slide_metadata}]
      tracker = Slideck::Tracker.for(slides.size)
      renderer = Slideck::Renderer.new(
        converter, ansi, cursor, width: screen.width, height: screen.height)
      i = -1
      presenter = described_class.new(
        reader, renderer, tracker, screen, output) do
        if (i += 1).zero?
          [metadata, slides]
        else
          [metadata, [{content: "reloaded#{i}", metadata: slide_metadata}]]
        end
      end
      input << "r" << ?\C-l << "q"
      input.rewind

      presenter.start

      expect(output.string.inspect).to eq([
        "\e[?25l\e[2J\e[1;1H",
        "\e[1;1Hslide1\n",
        "\e[8;16H1 / 2",
        "\e[2J\e[1;1H",
        "\e[1;1Hreloaded1\n",
        "\e[8;16H1 / 1",
        "\e[2J\e[1;1H",
        "\e[1;1Hreloaded2\n",
        "\e[8;16H1 / 1",
        "\e[2J\e[1;1H\e[?25h"
      ].join.inspect)
    end

    it "refreshes the slides when the screen size changes",
       unless: RSpec::Support::OS.windows? do
      slides = Array.new(5) do |i|
        {content: "slide#{i + 1}", metadata: slide_metadata}
      end
      tracker = Slideck::Tracker.for(slides.size)
      renderer = Slideck::Renderer.new(
        converter, ansi, cursor, width: screen.width, height: screen.height)
      allow(Signal).to receive(:trap).with("WINCH").and_yield
      presenter = described_class.new(
        reader, renderer, tracker, screen, output) do
        [metadata, slides]
      end
      input << "q"
      input.rewind

      presenter.start

      expect(output.string.inspect).to eq([
        "\e[?25l\e[2J\e[1;1H",
        "\e[1;1Hslide1\n",
        "\e[8;16H1 / 5",
        "\e[2J\e[1;1H",
        "\e[1;1Hslide1\n",
        "\e[8;16H1 / 5",
        "\e[2J\e[1;1H\e[?25h"
      ].join.inspect)
    end

    it "doesn't subscribe to the screen size change signal on Windows" do
      slides = []
      tracker = Slideck::Tracker.for(slides.size)
      screen = class_double(TTY::Screen, width: 20, height: 8, windows?: true)
      renderer = Slideck::Renderer.new(
        converter, ansi, cursor, width: screen.width, height: screen.height)
      allow(Signal).to receive(:trap)
      presenter = described_class.new(
        reader, renderer, tracker, screen, output) do
        [metadata, slides]
      end
      input << "q"
      input.rewind

      presenter.start

      expect(Signal).not_to have_received(:trap)
    end
  end
end
