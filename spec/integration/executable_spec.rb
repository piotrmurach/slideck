# frozen_string_literal: true

require "open3"

RSpec.describe "executable" do
  it "runs the slidedeck executable without an error and quits",
     unless: RSpec::Support::OS.windows? do
    slides_path = fixtures_path("slides.md")
    out, err, status = Open3.capture3("slideck #{slides_path}",
                                      stdin_data: "q")

    expect(out.inspect).to match(/Title.*footer content.*page 1 of 5/)
    expect(err).to eq("")
    expect(status.exitstatus).to eq(0)
  end
end
