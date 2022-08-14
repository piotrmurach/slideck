# frozen_string_literal: true

RSpec.describe Slideck::Metadata, ".from" do
  let(:alignment) { Slideck::Alignment }
  let(:converter) { Slideck::MetadataConverter.new(alignment) }
  let(:defaults) { Slideck::MetadataDefaults.new(alignment) }

  it "defaults :align to left top" do
    metadata = described_class.from(converter, {}, defaults)

    expect(metadata.align.to_a).to eq(%w[left top])
  end

  it "creates metadata from :align with a single value" do
    config = {align: "center"}

    metadata = described_class.from(converter, config, defaults)

    expect(metadata.align.to_a).to eq(%w[center center])
  end

  it "creates metadata from :align with two values" do
    config = {align: "center top"}

    metadata = described_class.from(converter, config, defaults)

    expect(metadata.align.to_a).to eq(%w[center top])
  end

  it "defaults :footer to empty" do
    metadata = described_class.from(converter, {}, defaults)

    expect(metadata.footer).to eq({
      align: alignment["left", "bottom"],
      text: ""
    })
    expect(metadata.footer?).to eq(false)
  end

  it "creates metadata from :footer with empty content" do
    config = {footer: ""}

    metadata = described_class.from(converter, config, defaults)

    expect(metadata.footer).to eq({
      align: alignment["left", "bottom"],
      text: ""
    })
    expect(metadata.footer?).to eq(false)
  end

  it "creates metadata from :footer with false value" do
    config = {footer: false}

    metadata = described_class.from(converter, config, defaults)

    expect(metadata.footer).to eq({
      align: alignment["left", "bottom"],
      text: ""
    })
    expect(metadata.footer?).to eq(false)
  end

  it "creates metadata from :footer" do
    config = {footer: "footer content"}

    metadata = described_class.from(converter, config, defaults)

    expect(metadata.footer).to eq({
      align: alignment["left", "bottom"],
      text: "footer content"
    })
    expect(metadata.footer?).to eq(true)
  end

  it "creates metadata from :footer with only :text" do
    config = {footer: {text: "footer text"}}

    metadata = described_class.from(converter, config, defaults)

    expect(metadata.footer).to eq({
      align: alignment["left", "bottom"],
      text: "footer text"
    })
    expect(metadata.footer?).to eq(true)
  end

  it "creates metadata from :footer with only horizontal alignment" do
    config = {
      footer: {
        align: "center",
        text: "footer content"
      }
    }

    metadata = described_class.from(converter, config, defaults)

    expect(metadata.footer).to eq({
      align: alignment["center", "bottom"],
      text: "footer content"
    })
    expect(metadata.footer?).to eq(true)
  end

  it "creates metadata from :footer with alignment for both axes" do
    config = {
      footer: {
        align: "center top",
        text: "footer content"
      }
    }

    metadata = described_class.from(converter, config, defaults)

    expect(metadata.footer).to eq({
      align: alignment["center", "top"],
      text: "footer content"
    })
    expect(metadata.footer?).to eq(true)
  end

  it "defaults :pager format to '%<page>d / %<total>d'" do
    metadata = described_class.from(converter, {}, defaults)

    expect(metadata.pager).to eq({
      align: alignment["right", "bottom"],
      text: "%<page>d / %<total>d"
    })
    expect(metadata.pager?).to eq(true)
  end

  it "creates metadata from :pager with empty content" do
    metadata = described_class.from(converter, {pager: ""}, defaults)

    expect(metadata.pager).to eq({
      align: alignment["right", "bottom"],
      text: ""
    })
    expect(metadata.pager?).to eq(false)
  end

  it "creates metadata from :pager with false value" do
    metadata = described_class.from(converter, {pager: false}, defaults)

    expect(metadata.pager).to eq({
      align: alignment["right", "bottom"],
      text: ""
    })
    expect(metadata.pager?).to eq(false)
  end

  it "creates metadata from :pager format with default alignment" do
    config = {pager: "page %<page>d of %<total>d"}

    metadata = described_class.from(converter, config, defaults)

    expect(metadata.pager).to eq({
      align: alignment["right", "bottom"],
      text: "page %<page>d of %<total>d"
    })
    expect(metadata.pager?).to eq(true)
  end

  it "creates metadata from :pager with only :text key" do
    config = {pager: {text: "page %<page>d of %<total>d"}}

    metadata = described_class.from(converter, config, defaults)

    expect(metadata.pager).to eq({
      align: alignment["right", "bottom"],
      text: "page %<page>d of %<total>d"
    })
    expect(metadata.pager?).to eq(true)
  end

  it "creates metadata from :pager with only horizontal alignment" do
    config = {
      pager: {
        align: "left",
        text: "page %<page>d of %<total>d"
      }
    }

    metadata = described_class.from(converter, config, defaults)

    expect(metadata.pager).to eq({
      align: alignment["left", "bottom"],
      text: "page %<page>d of %<total>d"
    })
    expect(metadata.pager?).to eq(true)
  end

  it "creates metadata from :pager with alignment for both axes" do
    config = {
      pager: {
        align: "left top",
        text: "page %<page>d of %<total>d"
      }
    }

    metadata = described_class.from(converter, config, defaults)

    expect(metadata.pager).to eq({
      align: alignment["left", "top"],
      text: "page %<page>d of %<total>d"
    })
    expect(metadata.pager?).to eq(true)
  end

  it "raises when invalid metadata key" do
    config = {invalid: ""}

    expect {
      described_class.from(converter, config, defaults)
    }.to raise_error(Slideck::InvalidMetadataKeyError,
                      "unknown 'invalid' configuration key\n" \
                      "Available keys are: :align, :footer, :pager")
  end
end
