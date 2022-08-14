# frozen_string_literal: true

RSpec.describe Slideck::MetadataDefaults, "#merge" do
  let(:alignment) { Slideck::Alignment }

  it "merges an empty hash" do
    defaults = described_class.new(alignment)

    merged = defaults.merge({})

    expect(merged).to eq({
      align: alignment["left", "top"],
      footer: {
        align: alignment["left", "bottom"],
        text: ""
      },
      pager: {
        align: alignment["right", "bottom"],
        text: "%<page>d / %<total>d"
      }
    })
  end

  it "merges custom metadata without alignments" do
    defaults = described_class.new(alignment)

    merged = defaults.merge({
      footer: {
        text: "footer"
      },
      pager: {
        text: "%<page>d of %<total>d"
      }
    })

    expect(merged).to eq({
      align: alignment["left", "top"],
      footer: {
        align: alignment["left", "bottom"],
        text: "footer"
      },
      pager: {
        align: alignment["right", "bottom"],
        text: "%<page>d of %<total>d"
      }
    })
  end

  it "merges custom metadata with alignments" do
    defaults = described_class.new(alignment)

    merged = defaults.merge({
      align: alignment["center", "center"],
      footer: {
        align: alignment["center", "top"]
      },
      pager: {
        align: alignment["right", "top"]
      }
    })

    expect(merged).to eq({
      align: alignment["center", "center"],
      footer: {
        align: alignment["center", "top"],
        text: ""
      },
      pager: {
        align: alignment["right", "top"],
        text: "%<page>d / %<total>d"
      }
    })
  end
end
