# frozen_string_literal: true

require "open3"

RSpec.describe "executable", :aggregate_failures do
  it "runs the slidedeck executable without an error and quits",
     unless: RSpec::Support::OS.windows? do
    slides_path = fixtures_path("slides.md")
    out, err, status = Open3.capture3("slideck #{slides_path}",
                                      stdin_data: "q")

    expect(out.inspect).to match(/Title.*footer content.*page 1 of 5/)
    expect(err).to eq("")
    expect(status.exitstatus).to eq(0)
  end

  it "runs the slideck executable with the --help flag and exits",
     unless: RSpec::Support::OS.windows? do
    out, err, status = Open3.capture3("slideck --help")

    expect(out.inspect).to match(/Usage: slideck \[OPTIONS\] FILE\\n/)
    expect(err).to eq("")
    expect(status.exitstatus).to eq(0)
  end

  it "runs the slideck executable with an error and exits",
     unless: RSpec::Support::OS.windows? do
    slides_path = fixtures_path("invalid.md")
    out, err, status = Open3.capture3("slideck #{slides_path}")

    expect(out.inspect).not_to match(/Usage: slideck \[OPTIONS\] FILE\\n/)
    expect(err).to eq("Error: unknown 'middle' horizontal alignment. " \
                      "Valid value is: left, center and right.\n")
    expect(status.exitstatus).to eq(1)
  end
end
