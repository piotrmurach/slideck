# frozen_string_literal: true

RSpec.describe Slideck::MetadataWrapper, "#wrap" do
  let(:alignment) { Slideck::Alignment }
  let(:margin) { Slideck::Margin }
  let(:metadata) { Slideck::Metadata }
  let(:converter) { Slideck::MetadataConverter.new(alignment, margin) }
  let(:defaults) { Slideck::MetadataDefaults.new(alignment, margin) }

  def build_metadata(custom_metadata)
    metadata.from(converter, custom_metadata, defaults)
  end

  def build_slide_metadata(custom_metadata)
    metadata.from(converter, custom_metadata, {})
  end

  it "wraps only empty global metadata with no slides" do
    deck = {
      metadata: {},
      slides: []
    }
    wrapper = described_class.new(metadata, converter, defaults)
    wrapped = wrapper.wrap(deck)

    expect(wrapped).to eq([build_metadata({}), []])
  end

  it "wraps empty global and individual slide metadata" do
    deck = {
      metadata: {},
      slides: [
        {content: "Slide 1", metadata: {}},
        {content: "Slide 2", metadata: {}},
        {content: "Slide 3", metadata: {}}
      ]
    }
    wrapper = described_class.new(metadata, converter, defaults)
    wrapped = wrapper.wrap(deck)

    expect(wrapped).to eq([
      build_metadata({}),
      [
        {content: "Slide 1", metadata: build_slide_metadata({})},
        {content: "Slide 2", metadata: build_slide_metadata({})},
        {content: "Slide 3", metadata: build_slide_metadata({})}
      ]
    ])
  end

  it "wraps global and individual slide metadata" do
    deck = {
      metadata: {margin: "2, 5"},
      slides: [
        {content: "Slide 1", metadata: {align: "center"}},
        {content: "Slide 2", metadata: {margin: "1, 2"}},
        {content: "Slide 2", metadata: {pager: {text: "pager"}}}
      ]
    }
    wrapper = described_class.new(metadata, converter, defaults)
    wrapped = wrapper.wrap(deck)

    expect(wrapped).to eq([
      build_metadata({margin: "2, 5"}),
      [
        {content: "Slide 1", metadata: build_slide_metadata({align: "center"})},
        {content: "Slide 2", metadata: build_slide_metadata({margin: "1, 2"})},
        {content: "Slide 2",
         metadata: build_slide_metadata({pager: {text: "pager"}})}
      ]
    ])
  end
end
