# frozen_string_literal: true

RSpec.describe Slideck, ".run" do
  it "creates a CLI with a runner" do
    cli = instance_spy(Slideck::CLI)
    allow(Slideck::CLI).to receive(:new).and_return(cli)

    described_class.run

    expect(Slideck::CLI).to have_received(:new)
      .with(instance_of(Slideck::Runner), $stdout, $stderr)
  end

  it "starts the CLI with a slides file and NO_COLOR=true variable" do
    cli = instance_spy(Slideck::CLI)
    allow(Slideck::CLI).to receive(:new).and_return(cli)

    described_class.run(%w[slides.md], {"NO_COLOR" => true})

    expect(cli).to have_received(:start)
      .with(%w[slides.md], {"NO_COLOR" => true})
  end
end
