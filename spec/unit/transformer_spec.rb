# frozen_string_literal: true

RSpec.describe Slideck::Transformer, "#read" do
  let(:loader) { Slideck::Loader.new(File) }
  let(:alignment) { Slideck::Alignment }
  let(:margin) { Slideck::Margin }
  let(:metadata) { Slideck::Metadata }
  let(:converter) { Slideck::MetadataConverter.new(alignment, margin) }
  let(:defaults) { Slideck::MetadataDefaults.new(alignment, margin) }
  let(:wrapper) { Slideck::MetadataWrapper.new(metadata, converter, defaults) }
  let(:parser_options) { {permitted_classes: [Symbol], symbolize_names: true} }
  let(:meta_parser) { Slideck::MetadataParser.new(YAML, **parser_options) }
  let(:parser) { Slideck::Parser.new(StringScanner, meta_parser) }

  def build_metadata(custom_metadata)
    metadata.from(converter, custom_metadata, defaults)
  end

  def build_slide_metadata(custom_metadata)
    metadata.from(converter, custom_metadata, {})
  end

  it "reads a file with no slides" do
    transformer = described_class.new(loader, parser, wrapper)

    meta_with_slides = transformer.read(fixtures_path("empty.md"))

    expect(meta_with_slides).to eq([build_metadata({}), []])
  end

  it "reads a file with slides" do
    transformer = described_class.new(loader, parser, wrapper)

    meta_with_slides = transformer.read(fixtures_path("slides.md"))

    expect(meta_with_slides).to eq([
      build_metadata({
        align: "center",
        footer: "**footer content**",
        margin: "1 2",
        pager: "page %<page>d of %<total>d",
        symbols: "ascii",
        theme: {
          header: %w[magenta underline],
          link: "cyan",
          list: "green",
          strong: "blue"
        }
      }),
      [
        {content: "\n# [Title](url)\n\n* Item 1\n* Item 2\n* Item 3\n",
         metadata: build_slide_metadata({
           symbols: {base: "ascii", override: {arrow: ">>"}}
         })},
        {content: "\nSlide 1\n",
         metadata: build_slide_metadata({align: "left"})},
        {content: "\nSlide 2\n",
         metadata: build_slide_metadata({pager: {text: "slide %<page>d"}})},
        {content: "\nSlide 3\n",
         metadata: build_slide_metadata({
           align: "right", footer: {text: "slide footer"}
         })},
        {content: "\nSummary",
         metadata: build_slide_metadata({})}
      ]
    ])
  end
end
