# frozen_string_literal: true

RSpec.describe Slideck::CLI, "#start" do
  let(:input) { StringIO.new("".dup, "w+") }
  let(:output) { StringIO.new("".dup, "w+") }
  let(:error_output) { StringIO.new("".dup, "w+") }
  let(:env) { {"TTY_TEST" => true} }
  let(:screen) { class_double(TTY::Screen, width: 40, height: 20) }
  let(:runner) { Slideck::Runner.new(screen, input, output, env) }

  it "starts with a slides file and --color=always option and quits" do
    cli = described_class.new(runner, output, error_output)
    input << "q"
    input.rewind

    cli.start([fixtures_path("slides.md"), "--color=always"], {})

    expect(output.string.inspect).to match(/\\e\[9;14H\\e\[35;4mTitle >>/)
  end

  it "starts with a slides file and --color=never option and quits" do
    cli = described_class.new(runner, output, error_output)
    input << "q"
    input.rewind

    cli.start([fixtures_path("slides.md"), "--color=never"], {})

    expect(output.string.inspect).to match(/\\e\[9;14HTitle >>/)
  end

  it "starts with a slides file and --no-color flag and quits" do
    cli = described_class.new(runner, output, error_output)
    input << "q"
    input.rewind

    cli.start([fixtures_path("slides.md"), "--no-color"], {})

    expect(output.string.inspect).to match(/\\e\[9;14HTitle >>/)
  end

  it "starts with a slides file and NO_COLOR=true variable and quits" do
    cli = described_class.new(runner, output, error_output)
    input << "q"
    input.rewind

    cli.start([fixtures_path("slides.md")], {"NO_COLOR" => "true"})

    expect(output.string.inspect).to match(/\\e\[9;14HTitle >>/)
  end

  it "starts with a slides file, NO_COLOR=true and --color=always option" do
    cli = described_class.new(runner, output, error_output)
    input << "q"
    input.rewind

    cli.start([fixtures_path("slides.md"), "--color=always"],
              {"NO_COLOR" => "true"})

    expect(output.string.inspect).to match(/\\e\[9;14H\\e\[35;4mTitle >>/)
  end

  it "fails to start with an invalid --color argument and exits" do
    cli = described_class.new(runner, output, error_output)

    expect {
      cli.start([fixtures_path("slides.md"), "--color=invalid"], {})
    }.to raise_error(SystemExit) { |err| expect(err.status).to eq(1) }

    expect(error_output.string)
      .to eq("Error: unpermitted value `invalid` for '--color' option: " \
             "choose from always,\n       auto, never\n")
  end

  it "fails to start with an invalid slides file and exits" do
    cli = described_class.new(runner, output, error_output)

    expect {
      cli.start([fixtures_path("invalid.md")], {})
    }.to raise_error(SystemExit) { |err| expect(err.status).to eq(1) }

    expect(error_output.string)
      .to eq("Error: unknown 'middle' horizontal alignment. " \
             "Valid value is: left, center and right.\n")
  end

  it "fails to start with an invalid slides file and --debug flag" do
    cli = described_class.new(runner, output, error_output)

    expect {
      cli.start([fixtures_path("invalid.md"), "--debug"], {})
    }.to raise_error(Slideck::InvalidArgumentError,
                     "unknown 'middle' horizontal alignment. " \
                     "Valid value is: left, center and right.")
  end

  it "prints help and exits" do
    cli = described_class.new(runner, output, error_output)

    expect {
      cli.start(%w[--help], {})
    }.to raise_error(SystemExit) { |err| expect(err.status).to eq(0) }

    expect(output.string).to eq unindent(<<-EOS)
      Usage: rspec [OPTIONS] FILE

      Present Markdown-powered slide decks in the terminal

      Controls:
        First  ^
        Go to  1..n+g
        Last   $
        Next   n, l, Right, Spacebar
        Prev   p, h, Left, Backspace
        Quit   q, Esc

      Options:
            --color WHEN  When to color output (permitted: always, auto, never)
                          (default "auto")
        -d, --debug       Run in debug mode
        -h, --help        Print usage
            --no-color    Do not color output. Identical to --color=never
        -v, --version     Print version

      Examples:
        Start presentation
        $ rspec slides.md
    EOS
  end

  it "prints help without a slides file and exits" do
    cli = described_class.new(runner, output, error_output)

    expect {
      cli.start([], {})
    }.to raise_error(SystemExit) { |err| expect(err.status).to eq(0) }

    expect(output.string).to match(/Usage: rspec \[OPTIONS\] FILE/)
  end

  it "prints the version number and exits" do
    cli = described_class.new(runner, output, error_output)

    expect {
      cli.start(%w[--version], {})
    }.to raise_error(SystemExit) { |err| expect(err.status).to eq(0) }

    expect(output.string).to eq("#{Slideck::VERSION}\n")
  end

  it "prints an error when given a slides file and an unknown option" do
    cli = described_class.new(runner, output, error_output)

    expect {
      cli.start([fixtures_path("slides.md"), "--unknown"], {})
    }.to raise_error(SystemExit) { |err| expect(err.status).to eq(1) }

    expect(error_output.string).to eq unindent(<<-EOS)
      Error: invalid option '--unknown'
    EOS
  end

  it "prints errors when given no slides file and an unknown option" do
    cli = described_class.new(runner, output, error_output)

    expect {
      cli.start(%w[--unknown], {})
    }.to raise_error(SystemExit) { |err| expect(err.status).to eq(1) }

    expect(error_output.string).to eq unindent(<<-EOS)
      Errors:
        1) Invalid option '--unknown'
        2) Argument 'file' must be provided
    EOS
  end
end
