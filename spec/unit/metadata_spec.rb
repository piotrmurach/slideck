# frozen_string_literal: true

RSpec.describe Slideck::Metadata do
  let(:alignment) { Slideck::Alignment }
  let(:margin) { Slideck::Margin }
  let(:converter) { Slideck::MetadataConverter.new(alignment, margin) }
  let(:defaults) { Slideck::MetadataDefaults.new(alignment, margin) }

  describe ".from" do
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
    end

    it "creates metadata from :footer with empty content" do
      config = {footer: ""}

      metadata = described_class.from(converter, config, defaults)

      expect(metadata.footer).to eq({
        align: alignment["left", "bottom"],
        text: ""
      })
    end

    it "creates metadata from :footer with false value" do
      config = {footer: false}

      metadata = described_class.from(converter, config, defaults)

      expect(metadata.footer).to eq({
        align: alignment["left", "bottom"],
        text: ""
      })
    end

    it "creates metadata from :footer" do
      config = {footer: "footer content"}

      metadata = described_class.from(converter, config, defaults)

      expect(metadata.footer).to eq({
        align: alignment["left", "bottom"],
        text: "footer content"
      })
    end

    it "creates metadata from :footer with only :text" do
      config = {footer: {text: "footer text"}}

      metadata = described_class.from(converter, config, defaults)

      expect(metadata.footer).to eq({
        align: alignment["left", "bottom"],
        text: "footer text"
      })
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
    end

    it "defaults :margin to zero for all sides" do
      metadata = described_class.from(converter, {}, defaults)

      expect(metadata.margin.to_a).to eq([0, 0, 0, 0])
    end

    it "creates metadata from :margin given as an integer" do
      config = {margin: 2}

      metadata = described_class.from(converter, config, defaults)

      expect(metadata.margin.to_a).to eq([2, 2, 2, 2])
    end

    it "creates metadata from :margin given as a string" do
      config = {margin: "1, 2, 3, 4"}

      metadata = described_class.from(converter, config, defaults)

      expect(metadata.margin.to_a).to eq([1, 2, 3, 4])
    end

    it "defaults :pager format to '%<page>d / %<total>d'" do
      metadata = described_class.from(converter, {}, defaults)

      expect(metadata.pager).to eq({
        align: alignment["right", "bottom"],
        text: "%<page>d / %<total>d"
      })
    end

    it "creates metadata from :pager with empty content" do
      metadata = described_class.from(converter, {pager: ""}, defaults)

      expect(metadata.pager).to eq({
        align: alignment["right", "bottom"],
        text: ""
      })
    end

    it "creates metadata from :pager with false value" do
      metadata = described_class.from(converter, {pager: false}, defaults)

      expect(metadata.pager).to eq({
        align: alignment["right", "bottom"],
        text: ""
      })
    end

    it "creates metadata from :pager format with default alignment" do
      config = {pager: "page %<page>d of %<total>d"}

      metadata = described_class.from(converter, config, defaults)

      expect(metadata.pager).to eq({
        align: alignment["right", "bottom"],
        text: "page %<page>d of %<total>d"
      })
    end

    it "creates metadata from :pager with only :text key" do
      config = {pager: {text: "page %<page>d of %<total>d"}}

      metadata = described_class.from(converter, config, defaults)

      expect(metadata.pager).to eq({
        align: alignment["right", "bottom"],
        text: "page %<page>d of %<total>d"
      })
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
    end

    it "defaults :symbols to :unicode" do
      metadata = described_class.from(converter, {}, defaults)

      expect(metadata.symbols).to eq(:unicode)
    end

    it "creates metadata from :symbols with an :ascii value" do
      config = {symbols: :ascii}

      metadata = described_class.from(converter, config, defaults)

      expect(metadata.symbols).to eq(:ascii)
    end

    it "defaults :theme to an empty hash" do
      metadata = described_class.from(converter, {}, defaults)

      expect(metadata.theme).to eq({})
    end

    it "creates metadata from :theme with a custom :link value" do
      config = {theme: {link: :magenta}}

      metadata = described_class.from(converter, config, defaults)

      expect(metadata.theme).to eq({link: :magenta})
    end

    it "raises when given an invalid metadata key" do
      expect {
        described_class.from(converter, {invalid: ""}, defaults)
      }.to raise_error(Slideck::InvalidMetadataKeyError,
                       "unknown 'invalid' configuration key\n" \
                       "Available keys are: :align, :footer, :margin, " \
                       ":pager, :symbols, :theme")
    end

    it "raises when given invalid metadata keys" do
      expect {
        described_class.from(converter, {invalid: "", unknown: ""}, defaults)
      }.to raise_error(Slideck::InvalidMetadataKeyError,
                       "unknown 'invalid, unknown' configuration keys\n" \
                       "Available keys are: :align, :footer, :margin, " \
                       ":pager, :symbols, :theme")
    end
  end

  describe "#==" do
    it "is equivalent with the same type and attributes" do
      config = {align: "center", footer: "footer", theme: {link: :magenta}}
      metadata = described_class.from(converter, config, defaults)
      same_metadata = described_class.from(converter, config, defaults)

      expect(metadata).to eq(same_metadata)
    end

    it "is not equivalent with the same type and different attributes" do
      metadata = described_class.from(converter, {footer: "a"}, defaults)
      other_metadata = described_class.from(converter, {footer: "b"}, defaults)

      expect(metadata).not_to eq(other_metadata)
    end

    it "is not equivalent with another type" do
      metadata = described_class.from(converter, {}, defaults)
      other = double(:metadata)

      expect(metadata).not_to eq(other)
    end
  end

  describe "#eql?" do
    it "is equal with the same type and attributes" do
      config = {align: "center", footer: "footer", theme: {link: :magenta}}
      metadata = described_class.from(converter, config, defaults)
      same_metadata = described_class.from(converter, config, defaults)

      expect(metadata).to eql(same_metadata)
    end

    it "is not equal with the same type and different attributes" do
      metadata = described_class.from(converter, {footer: "a"}, defaults)
      other_metadata = described_class.from(converter, {footer: "b"}, defaults)

      expect(metadata).not_to eql(other_metadata)
    end

    it "is not equal with another type" do
      metadata = described_class.from(converter, {}, defaults)
      other = double(:metadata)

      expect(metadata).not_to eql(other)
    end
  end

  describe "#hash" do
    it "calculates metadata hash" do
      config = {align: "center", footer: "footer", theme: {link: :magenta}}
      metadata = described_class.from(converter, config, defaults)

      expect(metadata.hash).to be_an(Integer)
    end

    it "calculate the same hash for equal metadata" do
      config = {align: "center", footer: "footer", theme: {link: :magenta}}
      metadata = described_class.from(converter, config, defaults)
      same_metadata = described_class.from(converter, config, defaults)

      expect(metadata.hash).to eq(same_metadata.hash)
    end
  end
end
