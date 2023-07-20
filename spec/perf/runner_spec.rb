# frozen_string_literal: true

require "rspec-benchmark"
require "tempfile"

RSpec.describe Slideck::Runner, "#run" do
  include RSpec::Benchmark::Matchers

  let(:input) { StringIO.new("".dup, "w+") }
  let(:output) { StringIO.new("".dup, "w+") }
  let(:env) { {"TTY_TEST" => true} }

  it "runs a presentation with 100 slides 200 times per second" do
    metadata = "align: center\nmargin: 1 2\nsymbols: ascii\n"
    slides = Array.new(100) { |i| "---\nSlide#{i}" }.join("\n")
    runner = described_class.new(TTY::Screen, input, output, env)

    Tempfile.create("slides.md") do |file|
      file << metadata
      file << slides
      input << "q"

      expect {
        file.rewind
        input.rewind
        runner.run(file.path, color: :always, watch: false)
      }.to perform_at_least(200).ips
    end
  end

  it "runs presentations with an increasing number of slides in linear time" do
    sizes = bench_range(10, 10_000)
    metadata = "align: center\nmargin: 1 2\nsymbols: ascii\n"
    slides = sizes.map { |n| Array.new(n) { |i| "---\nSlide#{i}" }.join("\n") }
    runner = described_class.new(TTY::Screen, input, output, env)

    Tempfile.create("slides.md") do |file|
      input << "q"

      expect { |_, i|
        file.rewind
        file << metadata
        file << slides[i]
        file.rewind
        input.rewind
        runner.run(file.path, color: :always, watch: false)
      }.to perform_linear.in_range(sizes)
    end
  end
end
