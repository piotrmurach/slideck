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
        "# Slide 1",
        "# Slide 2",
        "# Slide 3"
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
        "\n  # Slide 1\n\n  Content 1\n",
        "\n  # Slide 2\n\n  Content 2\n",
        "\n  # Slide 3\n\n  Content 3\n"
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
        "# Slide 1",
        "# Slide 2",
        "# Slide 3"
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
        "# Slide 1",
        "# Slide 2",
        "# Slide 3"
      ]
    })
  end
end
