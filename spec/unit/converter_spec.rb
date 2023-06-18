# frozen_string_literal: true

RSpec.describe Slideck::Converter, "#convert" do
  let(:markdown_parser) { TTY::Markdown }

  it "converts markdown title to terminal output" do
    converter = described_class.new(markdown_parser, color: :always)

    converted = converter.convert("# Title", symbols: :unicode, theme: {},
                                             width: 20)

    expect(converted).to eq("\e[36;1;4mTitle\e[0m\n")
  end

  it "converts markdown title to terminal output without color" do
    converter = described_class.new(markdown_parser, color: :never)

    converted = converter.convert("# Title", symbols: :unicode, theme: {},
                                             width: 20)

    expect(converted).to eq("Title\n")
  end

  it "converts markdown title limited by slide width" do
    converter = described_class.new(markdown_parser, color: :always)

    converted = converter.convert("# Very Long Title", symbols: :unicode,
                                                       theme: {}, width: 10)

    expect(converted).to eq([
      "\e[36;1;4mVery Long \e[0m\n",
      "\e[36;1;4mTitle\e[0m\n"
    ].join)
  end

  it "converts markdown title limited by slide width and without color" do
    converter = described_class.new(markdown_parser, color: :never)

    converted = converter.convert("# Very Long Title", symbols: :unicode,
                                                       theme: {}, width: 10)

    expect(converted).to eq([
      "Very Long \n",
      "Title\n"
    ].join)
  end

  it "converts a markdown list to terminal output with ascii symbols" do
    converter = described_class.new(markdown_parser, color: :always)

    converted = converter.convert("- list item", symbols: :ascii, theme: {},
                                                 width: 20)

    expect(converted).to eq("\e[33m*\e[0m list item\n")
  end

  it "converts a markdown list to terminal output with a custom theme" do
    converter = described_class.new(markdown_parser, color: :always)

    converted = converter.convert("- list item", symbols: :unicode,
                                                 theme: {list: :magenta},
                                                 width: 20)

    expect(converted).to eq("\e[35m●\e[0m list item\n")
  end

  it "raises when given an invalid color" do
    expect {
      described_class.new(markdown_parser, color: :invalid)
    }.to raise_error(Slideck::InvalidArgumentError,
                     "invalid value for color: :invalid.\n" \
                     "The color needs to be one of always, auto or never.")
  end
end
