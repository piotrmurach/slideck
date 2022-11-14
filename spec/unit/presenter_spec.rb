# frozen_string_literal: true

RSpec.describe Slideck::Presenter, "#start" do
  let(:output) { StringIO.new("".dup, "w+") }
  let(:input) { StringIO.new("".dup, "w+") }
  let(:env) { {"TTY_TEST" => true} }
  let(:reader) { TTY::Reader.new(input: input, output: output, env: env) }
  let(:ansi) { Strings::ANSI }
  let(:cursor) { TTY::Cursor }
  let(:markdown) { TTY::Markdown }
  let(:converter) { Slideck::Converter.new(markdown, color: true) }
  let(:alignment) { Slideck::Alignment }
  let(:margin) { Slideck::Margin }
  let(:meta_converter) { Slideck::MetadataConverter.new(alignment, margin) }
  let(:meta_defaults) { Slideck::MetadataDefaults.new(alignment, margin) }
  let(:metadata) { Slideck::Metadata.from(meta_converter, {}, meta_defaults) }
  let(:slide_metadata) { Slideck::Metadata.from(meta_converter, {}, {}) }

  it "quits slides immediately with 'q' key" do
    slides = [{content: "slide1", metadata: slide_metadata},
              {content: "slide2", metadata: slide_metadata},
              {content: "slide3", metadata: slide_metadata}]
    tracker = Slideck::Tracker.for(slides.size)
    renderer = Slideck::Renderer.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
    presenter = described_class.new(reader, renderer, tracker, output)
    input << "q"
    input.rewind

    presenter.start(slides)

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
    renderer = Slideck::Renderer.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
    presenter = described_class.new(reader, renderer, tracker, output)
    input << "n" << "l" << "p" << "h" << ?\C-x
    input.rewind

    presenter.start(slides)

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
    renderer = Slideck::Renderer.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
    presenter = described_class.new(reader, renderer, tracker, output)
    reader.on(:keypress) do |event|
      reader.trigger(:keyleft) if event.value == "a"
      reader.trigger(:keyright) if event.value == "d"
      reader.trigger(:keypage_up) if event.value == "w"
      reader.trigger(:keypage_down) if event.value == "s"
      reader.trigger(:keybackspace) if event.value == "b"
    end
    input << "d" << " " << "a" << "b" << "s" << "w" << "q"
    input.rewind

    presenter.start(slides)

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
    renderer = Slideck::Renderer.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
    presenter = described_class.new(reader, renderer, tracker, output)
    input << "$" << "^" << "\e"
    input.rewind

    presenter.start(slides)

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
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "navigates to a specific slide and exits with Ctrl+C" do
    slides = Array.new(15) do |i|
      {content: "slide#{i + 1}", metadata: slide_metadata}
    end
    tracker = Slideck::Tracker.for(slides.size)
    renderer = Slideck::Renderer.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)

    presenter = described_class.new(reader, renderer, tracker, output)
    input << "1" << "3" << "g" << "q" << ?\C-c
    input.rewind

    presenter.start(slides)

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
end
