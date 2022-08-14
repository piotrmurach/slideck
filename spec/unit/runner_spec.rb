# frozen_string_literal: true

RSpec.describe Slideck::Runner do
  let(:output) { StringIO.new("".dup, "w+") }
  let(:input) { StringIO.new("".dup, "w+") }
  let(:env) { {"TTY_TEST" => true} }

  describe ".default" do
    it "defaults all parameters for the initializer" do
      runner = described_class.default

      expect(runner).to be_an_instance_of(described_class)
    end
  end

  describe "#run" do
    it "displays no slides and quits" do
      screen = class_double(TTY::Screen, width: 40, height: 8)
      runner = described_class.new(screen, input, output, env, color: true)
      input << "q"
      input.rewind

      runner.run(fixtures_path("empty.md"))

      expect(output.string.inspect).to eq([
        "\e[?25l\e[2J\e[1;1H",
        "\e[8;36H1 / 0",
        "\e[2J\e[1;1H\e[?25h"
      ].join.inspect)
    end

    it "displays slides with color and quits" do
      screen = class_double(TTY::Screen, width: 40, height: 8)
      runner = described_class.new(screen, input, output, env, color: true)
      input << "q"
      input.rewind

      runner.run(fixtures_path("slides.md"))

      expect(output.string.inspect).to eq([
        "\e[?25l\e[2J\e[1;1H",
        "\e[4;18H\n",
        "\e[5;18H\e[36;1;4mTitle\e[0m\n",
        "\e[8;1H\e[33;1mfooter content\e[0m",
        "\e[8;30Hpage 1 of 5",
        "\e[2J\e[1;1H\e[?25h"
      ].join.inspect)
    end

    it "displays slides without color and quits" do
      screen = class_double(TTY::Screen, width: 40, height: 8)
      runner = described_class.new(screen, input, output, env, color: false)
      input << "q"
      input.rewind

      runner.run(fixtures_path("slides.md"))

      expect(output.string.inspect).to eq([
        "\e[?25l\e[2J\e[1;1H",
        "\e[4;18H\n",
        "\e[5;18HTitle\n",
        "\e[8;1Hfooter content",
        "\e[8;30Hpage 1 of 5",
        "\e[2J\e[1;1H\e[?25h"
      ].join.inspect)
    end
  end
end
