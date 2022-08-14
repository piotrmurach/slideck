# frozen_string_literal: true

RSpec.describe Slideck::Loader, "#load" do
  it "raises when no slides location is given" do
    loader = described_class.new(::File)

    expect {
      loader.load(nil)
    }.to raise_error(Slideck::ReadError,
                     "the location for the slides must be given")
  end

  it "raises when location doesn't exist" do
    loader = described_class.new(::File)

    expect {
      loader.load("unknown")
    }.to raise_error(Slideck::ReadError,
                     /No such file or directory.*unknown/)
  end
end
