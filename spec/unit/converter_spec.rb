# frozen_string_literal: true

RSpec.describe Slideck::Converter, "#convert" do
  let(:markdown_parser) { TTY::Markdown }

  it "converts markdown title to terminal output" do
    converter = described_class.new(markdown_parser, color: true)

    converted = converter.convert("# Title", width: 20)

    expect(converted).to eq("\e[36;1;4mTitle\e[0m\n")
  end

  it "converts markdown title to terminal output without color" do
    converter = described_class.new(markdown_parser, color: false)

    converted = converter.convert("# Title", width: 20)

    expect(converted).to eq("Title\n")
  end

  it "converts markdown title limited by slide width" do
    converter = described_class.new(markdown_parser, color: true)

    converted = converter.convert("# Very Long Title", width: 10)

    expect(converted).to eq([
      "\e[36;1;4mVery Long \e[0m\n",
      "\e[36;1;4mTitle\e[0m\n"
    ].join)
  end

  it "converts markdown title limited by slide width and without color" do
    converter = described_class.new(markdown_parser, color: false)

    converted = converter.convert("# Very Long Title", width: 10)

    expect(converted).to eq([
      "Very Long \n",
      "Title\n"
    ].join)
  end
end
