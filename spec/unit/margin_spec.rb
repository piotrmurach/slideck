# frozen_string_literal: true

RSpec.describe Slideck::Margin do
  describe ".from" do
    it "creates a margin from an integer" do
      margin = described_class.from(1)

      expect(margin).to have_attributes(top: 1, right: 1, bottom: 1, left: 1)
    end

    it "creates a margin from an array with a single integer" do
      margin = described_class.from([1])

      expect(margin).to have_attributes(top: 1, right: 1, bottom: 1, left: 1)
    end

    it "creates a margin from an array with two integers" do
      margin = described_class.from([1, 2])

      expect(margin).to have_attributes(top: 1, right: 2, bottom: 1, left: 2)
    end

    it "creates a margin from an array with three integers" do
      margin = described_class.from([1, 2, 3])

      expect(margin).to have_attributes(top: 1, right: 2, bottom: 3, left: 2)
    end

    it "creates a margin from an array with four integers" do
      margin = described_class.from([1, 2, 3, 4])

      expect(margin).to have_attributes(top: 1, right: 2, bottom: 3, left: 4)
    end

    it "raises when given an empty array" do
      expect {
        described_class.from([])
      }.to raise_error(Slideck::InvalidArgumentError,
                       "wrong number of integers for margin: \"\".\n" \
                       "The margin needs to be specified with one, two, " \
                       "three or four integers.")
    end

    it "raises when given an array with more than four integers" do
      expect {
        described_class.from([1, 2, 3, 4, 5])
      }.to raise_error(Slideck::InvalidArgumentError,
                       "wrong number of integers for margin: " \
                       "\"1, 2, 3, 4, 5\".\n" \
                       "The margin needs to be specified with one, two, " \
                       "three or four integers.")
    end

    it "creates a margin from a hash with all sides given" do
      margin = described_class.from({top: 1, right: 2, bottom: 3, left: 4})

      expect(margin).to have_attributes(top: 1, right: 2, bottom: 3, left: 4)
    end

    it "creates a margin from a hash with half of the sides given" do
      margin = described_class.from({right: 2, left: 4})

      expect(margin).to have_attributes(top: 0, right: 2, bottom: 0, left: 4)
    end

    it "raises when given a hash with an invalid side name" do
      expect {
        described_class.from_hash({invalid: 1})
      }.to raise_error(Slideck::InvalidArgumentError,
                       "unknown name for margin: :invalid.\n" \
                       "Valid names are: top, left, right and bottom.")
    end

    it "raises when given a hash with invalid side names" do
      expect {
        described_class.from_hash({invalid: 1, unknown: 2})
      }.to raise_error(Slideck::InvalidArgumentError,
                       "unknown names for margin: :invalid, :unknown.\n" \
                       "Valid names are: top, left, right and bottom.")
    end

    it "creates a margin from a string with two integers" do
      margin = described_class.from("1 2")

      expect(margin).to have_attributes(top: 1, right: 2, bottom: 1, left: 2)
    end

    it "creates a margin from a string with three comma-separated integers" do
      margin = described_class.from("1,2 ,  3")

      expect(margin).to have_attributes(top: 1, right: 2, bottom: 3, left: 2)
    end

    it "creates a margin from a string with four integers" do
      margin = described_class.from("1 2 3 4")

      expect(margin).to have_attributes(top: 1, right: 2, bottom: 3, left: 4)
    end

    it "raises when the margin is invalid" do
      expect {
        described_class.from("5%")
      }.to raise_error(Slideck::InvalidArgumentError,
                       "invalid value for margin: \"5%\".\n" \
                       "The margin needs to be an integer, a string of " \
                       "integers, an array of integers or a hash of side " \
                       "names and integer values.")
    end

    {
      top: ["one", ["one", 2, 3, 4]],
      right: ["two", [1, "two", 3, 4]],
      bottom: ["three", [1, 2, "three", 4]],
      left: ["four", [1, 2, 3, "four"]]
    }.each do |side, (val, margin)|
      it "accepts only integer for #{side} margin" do
        expect {
          described_class.from(margin)
        }.to raise_error(Slideck::InvalidArgumentError,
                         "#{side} margin needs to be an integer, " \
                         "got: #{val.inspect}")
      end
    end
  end

  describe ".[]" do
    it "creates a margin with array-like helper method" do
      margin = described_class[1, 2, 3, 4]

      expect(margin).to have_attributes(top: 1, right: 2, bottom: 3, left: 4)
    end

    it "raises when value is invalid" do
      expect {
        described_class[1.0, 2, 3, 4]
      }.to raise_error(Slideck::InvalidArgumentError,
                       "top margin needs to be an integer, got: 1.0")
    end

    it "raises when wrong number of integers" do
      expect {
        described_class[1, 2, 3, 4, 5]
      }.to raise_error(Slideck::InvalidArgumentError,
                       "wrong number of integers for margin: " \
                       "\"1, 2, 3, 4, 5\".\n" \
                       "The margin needs to be specified with one, two, " \
                       "three or four integers.")
    end
  end

  describe "#==" do
    it "is equivalent with the same type and attributes" do
      margin = described_class[1, 2, 3, 4]
      same_margin = described_class[1, 2, 3, 4]

      expect(margin).to eq(same_margin)
    end

    it "is not equivalent with the same type and different attributes" do
      margin = described_class[1, 2, 3, 4]
      other_margin = described_class[1, 2, 3, 0]

      expect(margin).not_to eq(other_margin)
    end

    it "is not equivalent with another type" do
      margin = described_class[1, 2, 3, 4]
      other = double(:margin)

      expect(margin).not_to eq(other)
    end
  end

  describe "#eql?" do
    it "is equal with the same type and attributes" do
      margin = described_class[1, 2, 3, 4]
      same_margin = described_class[1, 2, 3, 4]

      expect(margin).to eql(same_margin)
    end

    it "is not equal with the same type and different attributes" do
      margin = described_class[1, 2, 3, 4]
      other_margin = described_class[1, 2, 3, 0]

      expect(margin).not_to eql(other_margin)
    end

    it "is not equal with another type" do
      margin = described_class[1, 2, 3, 4]
      other = double(:margin)

      expect(margin).not_to eql(other)
    end
  end

  describe "#hash" do
    it "calculates margin hash" do
      margin = described_class[1, 2, 3, 4]

      expect(margin.hash).to be_an(Integer)
    end

    it "calculate the same hash for equal margins" do
      margin = described_class[1, 2, 3, 4]
      margin_same = described_class[1, 2, 3, 4]

      expect(margin.hash).to eq(margin_same.hash)
    end
  end

  describe "#to_a" do
    it "converts a margin into an array" do
      margin = described_class[1, 2, 3, 4]

      expect(margin.to_a).to eq([1, 2, 3, 4])
    end
  end
end
