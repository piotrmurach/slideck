# frozen_string_literal: true

RSpec.describe Slideck::Runner, "#run" do
  let(:output) { StringIO.new("".dup, "w+") }
  let(:input) { StringIO.new("".dup, "w+") }
  let(:env) { {"TTY_TEST" => true} }

  it "displays no slides and quits" do
    screen = class_double(TTY::Screen, width: 40, height: 10)
    runner = described_class.new(screen, input, output, env)
    input << "q"
    input.rewind

    runner.run(fixtures_path("empty.md"), color: :always)

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H",
      "\e[10;36H1 / 0",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "displays slides with color and quits" do
    screen = class_double(TTY::Screen, width: 40, height: 10)
    runner = described_class.new(screen, input, output, env)
    input << "q"
    input.rewind

    runner.run(fixtures_path("slides.md"), color: :always)

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H",
      "\e[3;14H\n",
      "\e[4;14H\e[35;4mTitle >> \e[36murl\e[0m\e[0m\n",
      "\e[5;14H\n",
      "\e[6;14H\e[32m*\e[0m Item 1\n",
      "\e[7;14H\e[32m*\e[0m Item 2\n",
      "\e[8;14H\e[32m*\e[0m Item 3\n",
      "\e[9;3H\e[34mfooter content\e[0m",
      "\e[9;28Hpage 1 of 5",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "displays slides without color and quits" do
    screen = class_double(TTY::Screen, width: 40, height: 10)
    runner = described_class.new(screen, input, output, env)
    input << "q"
    input.rewind

    runner.run(fixtures_path("slides.md"), color: :never)

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

  it "reloads slides from watched file and quits" do
    screen = class_double(TTY::Screen, width: 40, height: 10)
    listener = instance_spy(Listen::Listener)
    slides_file = fixtures_path("empty.md")
    allow(Listen).to receive(:to).and_yield([slides_file], [], [])
                                 .and_return(listener)
    runner = described_class.new(screen, input, output, env)
    input << "q"
    input.rewind

    runner.run(slides_file, color: :always, watch: true)

    expect(output.string.inspect).to eq([
      "\e[2J\e[1;1H",
      "\e[10;36H1 / 0",
      "\e[?25l\e[2J\e[1;1H",
      "\e[10;36H1 / 0",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "doesn't reload slides from an unchanged file and quits" do
    screen = class_double(TTY::Screen, width: 40, height: 10)
    listener = instance_spy(Listen::Listener)
    allow(Listen).to receive(:to).and_yield([], [], []).and_return(listener)
    runner = described_class.new(screen, input, output, env)
    input << "q"
    input.rewind

    runner.run(fixtures_path("empty.md"), color: :always, watch: true)

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H",
      "\e[10;36H1 / 0",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "stops the listener before quitting" do
    screen = class_double(TTY::Screen, width: 40, height: 10)
    listener = instance_spy(Listen::Listener)
    allow(Listen).to receive(:to).and_return(listener)
    runner = described_class.new(screen, input, output, env)
    input << "q"
    input.rewind

    runner.run(fixtures_path("slides.md"), color: :always, watch: true)

    expect(listener).to have_received(:stop)
  end

  it "doesn't watch for changes in file with slides" do
    screen = class_double(TTY::Screen, width: 40, height: 10)
    allow(Listen).to receive(:to)
    runner = described_class.new(screen, input, output, env)
    input << "q"
    input.rewind

    runner.run(fixtures_path("slides.md"), color: :always, watch: false)

    expect(Listen).not_to have_received(:to)
  end
end
