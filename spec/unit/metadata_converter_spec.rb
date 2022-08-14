# frozen_string_literal: true

RSpec.describe Slideck::MetadataConverter, "#convert" do
  let(:alignment) { Slideck::Alignment }

  it "converts :align value given as string" do
    converter = described_class.new(alignment)

    converted = converter.convert({align: "center"})

    expect(converted).to eq({align: alignment["center", "center"]})
  end

  it "converts :footer value given as false" do
    converter = described_class.new(alignment)

    converted = converter.convert({footer: false})

    expect(converted).to eq({footer: {text: ""}})
  end

  it "converts :footer value given as string" do
    converter = described_class.new(alignment)

    converted = converter.convert({footer: "footer"})

    expect(converted).to eq({footer: {text: "footer"}})
  end

  it "converts :footer value given as hash with alignment" do
    converter = described_class.new(alignment)

    converted = converter.convert({footer: {text: "footer", align: "center"}})

    expect(converted).to eq({
      footer: {
        text: "footer",
        align: alignment["center", "bottom"]
      }
    })
  end

  it "converts :pager value given as false" do
    converter = described_class.new(alignment)

    converted = converter.convert({pager: false})

    expect(converted).to eq({pager: {text: ""}})
  end

  it "converts :pager value given as string" do
    converter = described_class.new(alignment)

    converted = converter.convert({pager: "%<page>d of %<total>d"})

    expect(converted).to eq({pager: {text: "%<page>d of %<total>d"}})
  end

  it "converts :pager value given as hash with alignment" do
    converter = described_class.new(alignment)

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
