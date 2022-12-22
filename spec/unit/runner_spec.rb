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
      screen = class_double(TTY::Screen, width: 40, height: 10)
      runner = described_class.new(screen, input, output, env, color: true)
      input << "q"
      input.rewind

      runner.run(fixtures_path("empty.md"))

      expect(output.string.inspect).to eq([
        "\e[?25l\e[2J\e[1;1H",
        "\e[10;36H1 / 0",
        "\e[2J\e[1;1H\e[?25h"
      ].join.inspect)
    end

    it "displays slides with color and quits" do
      screen = class_double(TTY::Screen, width: 40, height: 10)
      runner = described_class.new(screen, input, output, env, color: true)
      input << "q"
      input.rewind

      runner.run(fixtures_path("slides.md"))

      expect(output.string.inspect).to eq([
        "\e[?25l\e[2J\e[1;1H",
        "\e[3;14H\n",
        "\e[4;14H\e[36;1;4mTitle >> \e[33;4murl\e[0m\e[0m\n",
        "\e[5;14H\n",
        "\e[6;14H\e[33m*\e[0m Item 1\n",
        "\e[7;14H\e[33m*\e[0m Item 2\n",
        "\e[8;14H\e[33m*\e[0m Item 3\n",
        "\e[9;3H\e[33;1mfooter content\e[0m",
        "\e[9;28Hpage 1 of 5",
        "\e[2J\e[1;1H\e[?25h"
      ].join.inspect)
    end

    it "displays slides without color and quits" do
      screen = class_double(TTY::Screen, width: 40, height: 10)
      runner = described_class.new(screen, input, output, env, color: false)
      input << "q"
      input.rewind

      runner.run(fixtures_path("slides.md"))

      expect(output.string.inspect).to eq([
        "\e[?25l\e[2J\e[1;1H",
        "\e[3;14H\n",
        "\e[4;14HTitle >> url\n",
        "\e[5;14H\n",
        "\e[6;14H* Item 1\n",
        "\e[7;14H* Item 2\n",
        "\e[8;14H* Item 3\n",
        "\e[9;3Hfooter content",
        "\e[9;28Hpage 1 of 5",
        "\e[2J\e[1;1H\e[?25h"
      ].join.inspect)
    end
  end
end
