# frozen_string_literal: true

RSpec.describe Slideck::Tracker do
  describe ".for" do
    it "creates a tracker with the current set to zero" do
      tracker = described_class.for(5)

      expect(tracker.current).to eq(0)
    end
  end

  describe "#current" do
    it "has access to the current slide number" do
      tracker = described_class.new(0, 5)

      expect(tracker.current).to eq(0)
    end
  end

  describe "#total" do
    it "has access to the total number of slides" do
      tracker = described_class.new(0, 5)

      expect(tracker.total).to eq(5)
    end
  end

  describe "#next, #previous" do
    it "changes by moving forward and backward" do
      tracker = described_class.new(0, 5)

      2.times { tracker = tracker.next }
      tracker = tracker.previous

      expect(tracker.current).to eq(1)
    end

    it "doesn't decrease before the first slide" do
      tracker = described_class.new(0, 5)

      3.times { tracker = tracker.previous }

      expect(tracker.current).to eq(0)
    end

    it "doesn't increase past the last slide" do
      tracker = described_class.new(0, 5)

      6.times { tracker = tracker.next }

      expect(tracker.current).to eq(4)
    end

    it "doesn't change when total is zero" do
      tracker = described_class.new(0, 0)

      3.times { tracker = tracker.next }
      3.times { tracker = tracker.previous }

      expect(tracker.current).to eq(0)
    end
  end

  describe "#first" do
    it "moves to the first slide" do
      tracker = described_class.new(3, 5)

      tracker = tracker.first

      expect(tracker.current).to eq(0)
    end
  end

  describe "#last" do
    it "moves to the last slide" do
      tracker = described_class.new(0, 5)

      tracker = tracker.last

      expect(tracker.current).to eq(4)
    end
  end

  describe "#go_to" do
    it "goes to a specified slide number between zero and total" do
      tracker = described_class.new(0, 5)

      tracker = tracker.go_to(3)

      expect(tracker.current).to eq(3)
    end

    it "doesn't change when more than total" do
      tracker = described_class.new(2, 5)

      tracker = tracker.go_to(5)

      expect(tracker.current).to eq(2)
    end

    it "doesn't change when less than zero" do
      tracker = described_class.new(2, 5)

      tracker = tracker.go_to(-1)

      expect(tracker.current).to eq(2)
    end
  end

  describe "#resize" do
    it "doesn't resize when the total is the same" do
      tracker = described_class.new(4, 5)

      tracker = tracker.resize(5)

      expect(tracker).to have_attributes(current: 4, total: 5)
    end

    it "doesn't resize when the total is less than zero" do
      tracker = described_class.new(4, 5)

      tracker = tracker.resize(-1)

      expect(tracker).to have_attributes(current: 4, total: 5)
    end

    it "resizes to a new total equal to zero" do
      tracker = described_class.new(4, 5)

      tracker = tracker.resize(0)

      expect(tracker).to have_attributes(current: 0, total: 0)
    end

    it "resizes to a new total greater than the current total" do
      tracker = described_class.new(4, 5)

      tracker = tracker.resize(6)

      expect(tracker).to have_attributes(current: 4, total: 6)
    end

    it "resizes to a new total less than the current total" do
      tracker = described_class.new(4, 5)

      tracker = tracker.resize(4)

      expect(tracker).to have_attributes(current: 3, total: 4)
    end
  end
end
