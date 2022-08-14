# frozen_string_literal: true

RSpec.describe Slideck::Alignment do
  describe ".from" do
    it "raises when horizontal value is invalid" do
      expect {
        described_class.from("unknown")
      }.to raise_error(Slideck::InvalidArgumentError,
                       "unknown 'unknown' horizontal alignment. " \
                       "Valid value is: left, center and right.")
    end

    it "raises when vertical value is invalid" do
      expect {
        described_class.from("center unknown")
      }.to raise_error(Slideck::InvalidArgumentError,
                       "unknown 'unknown' vertical alignment. " \
                       "Valid value is: top, center and bottom.")
    end

    it "creates alignment from a string with a single value" do
      alignment = described_class.from("right")

      expect(alignment.horizontal).to eq("right")
      expect(alignment.vertical).to eq("center")
    end

    it "creates alignment from a string with a single value and default" do
      alignment = described_class.from("right", default: "bottom")

      expect(alignment.horizontal).to eq("right")
      expect(alignment.vertical).to eq("bottom")
    end

    it "creates alignment from a string with two values space-separated" do
      alignment = described_class.from("right top")

      expect(alignment.horizontal).to eq("right")
      expect(alignment.vertical).to eq("top")
    end

    it "creates alignment from a string with a comma separator" do
      alignment = described_class.from("right,top")

      expect(alignment.horizontal).to eq("right")
      expect(alignment.vertical).to eq("top")
    end

    it "creates alignment from a string with a comma and space separator" do
      alignment = described_class.from("right , top")

      expect(alignment.horizontal).to eq("right")
      expect(alignment.vertical).to eq("top")
    end
  end

  describe ".[]" do
    it "creates alignemt with array-like helper method" do
      alignment = described_class["right", "top"]

      expect(alignment.horizontal).to eq("right")
      expect(alignment.vertical).to eq("top")
    end

    it "raises when value is invalid" do
      expect {
        described_class["right", "unknown"]
      }.to raise_error(Slideck::InvalidArgumentError,
                       "unknown 'unknown' vertical alignment. " \
                       "Valid value is: top, center and bottom.")
    end
  end

  describe "#==" do
    it "is equivalent with the same type and attributes" do
      alignment = described_class["center", "center"]
      same_alignment = described_class["center", "center"]

      expect(alignment).to eq(same_alignment)
    end

    it "is not equivalent with the same type and different attributes" do
      alignment = described_class["center", "center"]
      other_alignment = described_class["right", "top"]

      expect(alignment).not_to eq(other_alignment)
    end

    it "is not equivalent with another type" do
      alignment = described_class["center", "center"]
      other = double(:alignment)

      expect(alignment).not_to eq(other)
    end
  end

  describe "#eql?" do
    it "is equal with the same type and attributes" do
      alignment = described_class["center", "center"]
      same_alignment = described_class["center", "center"]

      expect(alignment).to eql(same_alignment)
    end

    it "is not equal with the same type and different attributes" do
      alignment = described_class["center", "center"]
      other_alignment = described_class["right", "top"]

      expect(alignment).not_to eql(other_alignment)
    end

    it "is not equal with another type" do
      alignment = described_class["center", "center"]
      other = double(:alignment)

      expect(alignment).not_to eql(other)
    end
  end

  describe "#hash" do
    it "calculates alignment hash" do
      alignment = described_class["center", "top"]

      expect(alignment.hash).to be_an(Integer)
    end

    it "calculate the same hash for equal alignments" do
      alignment = described_class["center", "top"]
      alignment_same = described_class["center", "top"]

      expect(alignment.hash).to eq(alignment_same.hash)
    end
  end

  describe "#to_a" do
    it "converts alignment into array" do
      alignment = described_class["center", "top"]

      expect(alignment.to_a).to eq(%w[center top])
    end
  end
end
