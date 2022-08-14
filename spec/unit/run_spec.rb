# frozen_string_literal: true

RSpec.describe Slideck, ".run" do
  it "runs the runner" do
    runner = instance_double(Slideck::Runner)
    allow(runner).to receive(:run).with("slides.md")
    allow(Slideck::Runner).to receive(:default).and_return(runner)

    described_class.run("slides.md")

    expect(Slideck::Runner).to have_received(:default)
    expect(runner).to have_received(:run).with("slides.md")
  end
end
