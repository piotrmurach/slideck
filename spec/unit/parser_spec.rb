# frozen_string_literal: true

RSpec.describe Slideck::Parser, "#parse" do
  let(:metadata_parser) {
    Slideck::MetadataParser.new(::YAML, permitted_classes: [Symbol],
                                        symbolize_names: true)
  }

  it "parses empty content" do
    parser = described_class.new(StringScanner, metadata_parser)

    deck = parser.parse("")

    expect(deck).to eq({
      metadata: {},
      slides: []
    })
  end

  it "parses slides with content" do
    content = unindent(<<-EOS)
    # Slide 1
    ---
    # Slide 2
    ---
    # Slide 3
    EOS
    parser = described_class.new(StringScanner, metadata_parser)

    deck = parser.parse(content)

    expect(deck).to eq({
      metadata: {},
      slides: [
        {content: "# Slide 1", metadata: {}},
        {content: "# Slide 2", metadata: {}},
        {content: "# Slide 3", metadata: {}}
      ]
    })
  end

  it "parses slides with sparse content and newlines" do
    content = unindent(<<-EOS)

      # Slide 1

      Content 1

    ------

      # Slide 2

      Content 2

    ------

      # Slide 3

      Content 3

    EOS
    parser = described_class.new(StringScanner, metadata_parser)

    deck = parser.parse(content)

    expect(deck).to eq({
      metadata: {},
      slides: [
        {content: "\n  # Slide 1\n\n  Content 1\n", metadata: {}},
        {content: "\n  # Slide 2\n\n  Content 2\n", metadata: {}},
        {content: "\n  # Slide 3\n\n  Content 3\n", metadata: {}}
      ]
    })
  end

  it "parses only metadata" do
    content = unindent(<<-EOS)
    align: center
    footer: footer content
    pager: "page %<page>d of %<total>d"
    EOS
    parser = described_class.new(StringScanner, metadata_parser)

    deck = parser.parse(content)

    expect(deck).to eq({
      metadata: {
        align: "center",
        footer: "footer content",
        pager: "page %<page>d of %<total>d"
      },
      slides: []
    })
  end

  it "parses only indented metadata with symbol keys" do
    content = unindent(<<-EOS)
      :align: center
      :footer: footer content
      :pager: "page %<page>d of %<total>d"
    EOS
    parser = described_class.new(StringScanner, metadata_parser)

    deck = parser.parse(content)

    expect(deck).to eq({
      metadata: {
        align: "center",
        footer: "footer content",
        pager: "page %<page>d of %<total>d"
      },
      slides: []
    })
  end

  it "parses slides with content and metadata" do
    content = unindent(<<-EOS)
    align: center
    footer: footer content
    pager: "page %<page>d of %<total>d"
    ---
    # Slide 1
    ---
    # Slide 2
    ---
    # Slide 3
    EOS
    parser = described_class.new(StringScanner, metadata_parser)

    deck = parser.parse(content)

    expect(deck).to eq({
      metadata: {
        align: "center",
        footer: "footer content",
        pager: "page %<page>d of %<total>d"
      },
      slides: [
        {content: "# Slide 1", metadata: {}},
        {content: "# Slide 2", metadata: {}},
        {content: "# Slide 3", metadata: {}}
      ]
    })
  end

  it "parses slides with content and metadata wrapped with slide separator" do
    content = unindent(<<-EOS)
    ---
    align: center
    footer: footer content
    pager: "page %<page>d of %<total>d"
    ---
    # Slide 1
    ---
    # Slide 2
    ---
    # Slide 3
    ---
    EOS
    parser = described_class.new(StringScanner, metadata_parser)

    deck = parser.parse(content)

    expect(deck).to eq({
      metadata: {
        align: "center",
        footer: "footer content",
        pager: "page %<page>d of %<total>d"
      },
      slides: [
        {content: "# Slide 1", metadata: {}},
        {content: "# Slide 2", metadata: {}},
        {content: "# Slide 3", metadata: {}}
      ]
    })
  end

  it "parses slides with slide metadata" do
    content = unindent(<<-EOS)
    ---align: center

    Slide 1

    --- { align: "left, top" , pager: false }

    Slide 2

    ---{align: right, footer: {align: left, text: slide footer}}

    Slide 3

    --- pager: {text: page %<page>d of %<total>d}

    Slide 4
    EOS
    parser = described_class.new(StringScanner, metadata_parser)

    deck = parser.parse(content)

    expect(deck).to eq({
      metadata: {},
      slides: [
        {content: "\nSlide 1\n", metadata: {align: "center"}},
        {content: "\nSlide 2\n", metadata: {align: "left, top", pager: false}},
        {content: "\nSlide 3\n",
         metadata: {align: "right",
                    footer: {align: "left", text: "slide footer"}}},
        {content: "\nSlide 4",
         metadata: {pager: {text: "page %<page>d of %<total>d"}}}
      ]
    })
  end
end
