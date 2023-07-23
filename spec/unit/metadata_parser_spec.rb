# frozen_string_literal: true

RSpec.describe Slideck::MetadataParser, "#parse" do
  it "parses without symbolizing names" do
    parser = described_class.new(YAML, permitted_classes: [],
                                       symbolize_names: false)

    metadata = parser.parse("align: center\nfooter: footer content")

    expect(metadata).to eq({
      "align" => "center",
      "footer" => "footer content"
    })
  end

  it "parses with symbolizing names" do
    parser = described_class.new(YAML, permitted_classes: [],
                                       symbolize_names: true)

    metadata = parser.parse("align: center\nfooter: footer content")

    expect(metadata).to eq({
      align: "center",
      footer: "footer content"
    })
  end

  it "parses without custom symbolizing names" do
    parser = described_class.new(YAML, permitted_classes: [],
                                       symbolize_names: false)
    allow(parser).to receive(:parse_method_params).and_return([])

    metadata = parser.parse("align: center\nfooter: footer content")

    expect(metadata).to eq({
      "align" => "center",
      "footer" => "footer content"
    })
  end

  it "parses with custom symbolizing names" do
    content = unindent(<<-EOS)
    align: center
    footer:
      - align: left
      - text: footer content
    EOS
    parser = described_class.new(YAML, permitted_classes: [],
                                       symbolize_names: true)
    allow(parser).to receive(:parse_method_params).and_return([])

    metadata = parser.parse(content)

    expect(metadata).to eq({
      align: "center",
      footer: [{align: "left"}, {text: "footer content"}]
    })
  end

  it "parses permitting symbols as an argument" do
    yaml_parser = double(:yaml, safe_load: {})
    parser = described_class.new(yaml_parser, permitted_classes: [Symbol],
                                              symbolize_names: false)
    allow(parser).to receive(:parse_method_params)
      .and_return(%i[whitelist_classes])

    parser.parse(":align: center")

    expect(yaml_parser).to have_received(:safe_load)
      .with(":align: center", [Symbol], any_args)
  end

  it "parses permitting symbols as an option" do
    yaml_parser = double(:yaml, load: {})
    parser = described_class.new(yaml_parser, permitted_classes: [Symbol],
                                              symbolize_names: false)
    allow(parser).to receive(:parse_method_params)
      .and_return(%i[permitted_classes])

    parser.parse(":align: center")

    expect(yaml_parser).to have_received(:load)
      .with(":align: center", {permitted_classes: [Symbol]})
  end
end
