# frozen_string_literal: true

RSpec.describe Slideck::MetadataDefaults, "#merge" do
  let(:alignment) { Slideck::Alignment }
  let(:margin) { Slideck::Margin }

  it "merges an empty hash" do
    defaults = described_class.new(alignment, margin)

    merged = defaults.merge({})

    expect(merged).to eq({
      align: alignment["left", "top"],
      footer: {
        align: alignment["left", "bottom"],
        text: ""
      },
      margin: margin[0, 0, 0, 0],
      pager: {
        align: alignment["right", "bottom"],
        text: "%<page>d / %<total>d"
      },
      symbols: :unicode
    })
  end

  it "merges custom metadata without alignments" do
    defaults = described_class.new(alignment, margin)

    merged = defaults.merge({
      footer: {
        text: "footer"
      },
      margin: margin[1, 2, 3, 4],
      pager: {
        text: "%<page>d of %<total>d"
      },
      symbols: :ascii
    })

    expect(merged).to eq({
      align: alignment["left", "top"],
      footer: {
        align: alignment["left", "bottom"],
        text: "footer"
      },
      margin: margin[1, 2, 3, 4],
      pager: {
        align: alignment["right", "bottom"],
        text: "%<page>d of %<total>d"
      },
      symbols: :ascii
    })
  end

  it "merges custom metadata with alignments" do
    defaults = described_class.new(alignment, margin)

    merged = defaults.merge({
      align: alignment["center", "center"],
      footer: {
        align: alignment["center", "top"]
      },
      margin: margin[1, 2, 3, 4],
      pager: {
        align: alignment["right", "top"]
      },
      symbols: :ascii
    })

    expect(merged).to eq({
      align: alignment["center", "center"],
      footer: {
        align: alignment["center", "top"],
        text: ""
      },
      margin: margin[1, 2, 3, 4],
      pager: {
        align: alignment["right", "top"],
        text: "%<page>d / %<total>d"
      },
      symbols: :ascii
    })
  end
end
