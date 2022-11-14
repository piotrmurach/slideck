# frozen_string_literal: true

RSpec.describe Slideck::MetadataConverter, "#convert" do
  let(:alignment) { Slideck::Alignment }
  let(:margin) { Slideck::Margin }

  it "converts :align value given as a string" do
    converter = described_class.new(alignment, margin)

    converted = converter.convert({align: "center"})

    expect(converted).to eq({align: alignment["center", "center"]})
  end

  it "converts :footer value given as a false value" do
    converter = described_class.new(alignment, margin)

    converted = converter.convert({footer: false})

    expect(converted).to eq({footer: {text: ""}})
  end

  it "converts :footer value given as a string" do
    converter = described_class.new(alignment, margin)

    converted = converter.convert({footer: "footer"})

    expect(converted).to eq({footer: {text: "footer"}})
  end

  it "converts :footer value given as a hash with alignment" do
    converter = described_class.new(alignment, margin)

    converted = converter.convert({footer: {text: "footer", align: "center"}})

    expect(converted).to eq({
      footer: {
        text: "footer",
        align: alignment["center", "bottom"]
      }
    })
  end

  it "converts :margin value given as an integer" do
    converter = described_class.new(alignment, margin)

    converted = converter.convert({margin: 2})

    expect(converted).to eq({margin: margin[2]})
  end

  it "converts :margin value given as a string" do
    converter = described_class.new(alignment, margin)

    converted = converter.convert({margin: "1, 2"})

    expect(converted).to eq({margin: margin[1, 2]})
  end

  it "converts :pager value given as a false value" do
    converter = described_class.new(alignment, margin)

    converted = converter.convert({pager: false})

    expect(converted).to eq({pager: {text: ""}})
  end

  it "converts :pager value given as a string" do
    converter = described_class.new(alignment, margin)

    converted = converter.convert({pager: "%<page>d of %<total>d"})

    expect(converted).to eq({pager: {text: "%<page>d of %<total>d"}})
  end

  it "converts :pager value given as a hash with alignment" do
    converter = described_class.new(alignment, margin)

    converted = converter.convert({
      pager: {
        text: "%<page>d of %<total>d",
        align: "right top"
      }
    })

    expect(converted).to eq({
      pager: {
        text: "%<page>d of %<total>d",
        align: alignment["right", "top"]
      }
    })
  end
end
