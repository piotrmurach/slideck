# frozen_string_literal: true

RSpec.describe Slideck::Renderer do
  let(:ansi) { Strings::ANSI }
  let(:cursor) { TTY::Cursor }
  let(:markdown) { TTY::Markdown }
  let(:converter) { Slideck::Converter.new(markdown, color: true) }
  let(:alignment) { Slideck::Alignment }
  let(:margin) { Slideck::Margin }
  let(:meta_defaults) { Slideck::MetadataDefaults.new(alignment, margin) }
  let(:meta_converter) { Slideck::MetadataConverter.new(alignment, margin) }

  def build_metadata(custom_metadata)
    Slideck::Metadata.from(meta_converter, custom_metadata, meta_defaults)
  end

  def build_slide_metadata(custom_metadata)
    Slideck::Metadata.from(meta_converter, custom_metadata, {})
  end

  describe "#render" do
    it "renders page number without slide content" do
      metadata = build_metadata({})
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)

      expect(renderer.render(nil, 0, 0).inspect).to eq([
        "\e[8;16H0 / 0"
      ].join.inspect)
    end

    it "renders footer without slide content and pager" do
      metadata = build_metadata({footer: "footer", pager: ""})
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)

      expect(renderer.render(nil, 0, 0).inspect).to eq([
        "\e[8;1Hfooter"
      ].join.inspect)
    end

    it "renders slide content without footer and pager" do
      metadata = build_metadata({footer: "", pager: ""})
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
      slide = {content: "content", metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 0, 0).inspect).to eq([
        "\e[1;1Hcontent\n"
      ].join.inspect)
    end

    it "renders multiline content with page number" do
      metadata = build_metadata({})
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
      slide = {content: "line1\nline2\nline3",
               metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1Hline1\n",
        "\e[2;1Hline2\n",
        "\e[3;1Hline3\n",
        "\e[8;16H1 / 4"
      ].join.inspect)
    end

    {
      "left top" => "1;1",
      "center top" => "1;7",
      "right top" => "1;13",
      "left" => "4;1",
      "center" => "4;7",
      "right" => "4;13",
      "left bottom" => "8;1",
      "center bottom" => "8;7",
      "right bottom" => "8;13"
    }.each do |align, pos|
      it "renders slide with content at #{align.inspect}" do
        metadata = build_metadata({align: align})
        renderer = described_class.new(converter, ansi, cursor, metadata,
                                       width: 20, height: 8)
        slide = {content: "content", metadata: build_slide_metadata({})}

        expect(renderer.render(slide, 1, 4).inspect).to eq([
          "\e[#{pos}Hcontent\n",
          "\e[8;16H1 / 4"
        ].join.inspect)
      end
    end

    it "renders content with a margin" do
      metadata = build_metadata({margin: [1, 2, 3, 4]})
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 10)
      slide = {content: "content", metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[2;5Hcontent\n",
        "\e[7;14H1 / 4"
      ].join.inspect)
    end

    it "renders multiline content with a margin" do
      metadata = build_metadata({margin: [1, 2, 3, 4]})
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 10)
      slide = {content: "line1\nline2\nline3",
               metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[2;5Hline1\n",
        "\e[3;5Hline2\n",
        "\e[4;5Hline3\n",
        "\e[7;14H1 / 4"
      ].join.inspect)
    end

    it "renders long content with a margin" do
      metadata = build_metadata({margin: [1, 2, 3, 4]})
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 10)
      slide = {content: "It is not down on any map; true places never are.",
               metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[2;5HIt is not \n",
        "\e[3;5Hdown on any \n",
        "\e[4;5Hmap; true \n",
        "\e[5;5Hplaces never \n",
        "\e[6;5Hare.\n",
        "\e[7;14H1 / 4"
      ].join.inspect)
    end

    it "renders content with a footer and margin" do
      metadata = build_metadata({
        footer: "footer",
        margin: [1, 2, 3, 4]
      })
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 10)
      slide = {content: "content", metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[2;5Hcontent\n",
        "\e[7;5Hfooter",
        "\e[7;14H1 / 4"
      ].join.inspect)
    end

    it "renders a markdown list" do
      metadata = build_metadata({})
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
      content = unindent(<<-EOS)
        # List
        - a
        - b
        - c
      EOS
      slide = {content: content, metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1H\e[36;1;4mList\e[0m\n",
        "\e[2;1H\e[33m●\e[0m a\n",
        "\e[3;1H\e[33m●\e[0m b\n",
        "\e[4;1H\e[33m●\e[0m c\n",
        "\e[8;16H1 / 4"
      ].join.inspect)
    end

    it "renders a markdown list without colors" do
      metadata = build_metadata({})
      converter = Slideck::Converter.new(markdown, color: false)
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
      content = unindent(<<-EOS)
        # List
        - a
        - b
        - c
      EOS
      slide = {content: content, metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1HList\n",
        "\e[2;1H● a\n",
        "\e[3;1H● b\n",
        "\e[4;1H● c\n",
        "\e[8;16H1 / 4"
      ].join.inspect)
    end

    it "renders a markdown list with ascii symbols" do
      metadata = build_metadata({
        symbols: :ascii
      })
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
      content = unindent(<<-EOS)
        # List
        - a
        - b
        - c
      EOS
      slide = {content: content, metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1H\e[36;1;4mList\e[0m\n",
        "\e[2;1H\e[33m*\e[0m a\n",
        "\e[3;1H\e[33m*\e[0m b\n",
        "\e[4;1H\e[33m*\e[0m c\n",
        "\e[8;16H1 / 4"
      ].join.inspect)
    end

    it "renders a markdown list with overridden symbols" do
      metadata = build_metadata({
        symbols: {
          override: {
            bullet: "x"
          }
        }
      })
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
      content = unindent(<<-EOS)
        # List
        - a
        - b
        - c
      EOS
      slide = {content: content, metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1H\e[36;1;4mList\e[0m\n",
        "\e[2;1H\e[33mx\e[0m a\n",
        "\e[3;1H\e[33mx\e[0m b\n",
        "\e[4;1H\e[33mx\e[0m c\n",
        "\e[8;16H1 / 4"
      ].join.inspect)
    end

    it "renders a markdown list with a custom theme" do
      metadata = build_metadata({
        theme: {
          header: %i[magenta underline],
          list: :green
        }
      })
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)

      content = unindent(<<-EOS)
        # List
        - a
        - b
        - c
      EOS
      slide = {content: content, metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1H\e[35;4mList\e[0m\n",
        "\e[2;1H\e[32m●\e[0m a\n",
        "\e[3;1H\e[32m●\e[0m b\n",
        "\e[4;1H\e[32m●\e[0m c\n",
        "\e[8;16H1 / 4"
      ].join.inspect)
    end

    it "renders content with footer and page number" do
      metadata = build_metadata({footer: "footer"})
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
      slide = {content: "content", metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1Hcontent\n",
        "\e[8;1Hfooter\e[8;16H1 / 4"
      ].join.inspect)
    end

    it "renders content with footer in markdown and page number" do
      metadata = build_metadata({footer: "**bold** footer"})
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
      slide = {content: "content", metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1Hcontent\n",
        "\e[8;1H\e[33;1mbold\e[0m footer\e[8;16H1 / 4"
      ].join.inspect)
    end

    it "renders the footer and pager content with ascii symbols" do
      metadata = build_metadata({
        symbols: "ascii",
        footer: "- footer",
        pager: "- %<page>d of %<total>d"
      })
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
      slide = {content: "- content", metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1H\e[33m*\e[0m content\n",
        "\e[8;1H\e[33m*\e[0m footer",
        "\e[8;13H\e[33m*\e[0m 1 of 4"
      ].join.inspect)
    end

    it "renders the footer and pager content with a custom theme" do
      metadata = build_metadata({
        footer: "**footer**",
        pager: "*%<page>d / %<total>d*",
        theme: {
          em: :cyan,
          strong: %i[magenta underline]
        }
      })
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
      slide = {content: "content", metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1Hcontent\n",
        "\e[8;1H\e[35;4mfooter\e[0m",
        "\e[8;16H\e[36m1 / 4\e[0m"
      ].join.inspect)
    end

    it "renders content and page number with markdown" do
      metadata = build_metadata({pager: "**%<page>s of %<total>s**"})
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
      slide = {content: "content", metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1Hcontent\n",
        "\e[8;15H\e[33;1m1 of 4\e[0m"
      ].join.inspect)
    end

    it "renders content with footer centered and page number" do
      metadata = build_metadata({
        footer: {
          align: "center",
          text: "footer"
        }
      })
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
      slide = {content: "content", metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1Hcontent\n",
        "\e[8;8Hfooter\e[8;16H1 / 4"
      ].join.inspect)
    end

    [
      [{align: "center", pos: "8;8"}, {align: "left", pos: "8;1"}],
      [{align: "right", pos: "8;15"}, {align: "center", pos: "8;8"}],
      [{align: "left top", pos: "1;1"}, {align: "right top", pos: "1;15"}],
      [{align: "center top", pos: "1;8"}, {align: "left top", pos: "1;1"}]
    ].each do |footer, pager|
      it "renders footer at #{footer[:align]} and pager at #{pager[:align]}" do
        metadata = build_metadata({
          footer: {
            align: footer[:align],
            text: "footer"
          },
          pager: {
            align: pager[:align],
            text: "%<page>d of %<total>d"
          }
        })
        renderer = described_class.new(converter, ansi, cursor, metadata,
                                       width: 20, height: 8)
        slide = {content: "content", metadata: build_slide_metadata({})}

        expect(renderer.render(slide, 1, 4).inspect).to eq([
          "\e[1;1Hcontent\n",
          "\e[#{footer[:pos]}Hfooter\e[#{pager[:pos]}H1 of 4"
        ].join.inspect)
      end
    end

    it "renders content with footer right aligned and no page number" do
      metadata = build_metadata({
        footer: {
          text: "footer",
          align: "right"
        },
        pager: ""
      })
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
      slide = {content: "content", metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1Hcontent\n",
        "\e[8;15Hfooter"
      ].join.inspect)
    end

    it "renders multiline footer and multiline pager" do
      metadata = build_metadata({
        footer: {
          align: "center",
          text: "footer1\nfooter2\nfooter3"
        },
        pager: {
          text: "%<page>d\n%<total>d"
        }
      })
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)
      slide = {content: "content", metadata: build_slide_metadata({})}

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1Hcontent\n",
        "\e[6;7Hfooter1\n",
        "\e[7;7Hfooter2\n",
        "\e[8;7Hfooter3",
        "\e[7;19H1\n",
        "\e[8;19H4"
      ].join.inspect)
    end

    it "renders content with overridden alignment, footer, margin and pager" do
      metadata = build_metadata({
        align: "left",
        footer: {
          align: "center",
          text: "global footer"
        }
      })
      slide_metadata = build_slide_metadata({
        align: "right",
        footer: {
          align: "left",
          text: "slide footer"
        },
        margin: [1, 2, 3, 4],
        pager: {
          align: "center",
          text: "%<page>d of %<total>d"
        }
      })
      slide = {content: "content", metadata: slide_metadata}
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[3;11Hcontent\n",
        "\e[5;5Hslide footer",
        "\e[5;9H1 of 4"
      ].join.inspect)
    end

    it "renders content with global metadata and no footer or pager" do
      metadata = build_metadata({
        footer: {
          align: "center",
          text: "global footer"
        }
      })
      slide_metadata = build_slide_metadata({
        footer: "",
        pager: ""
      })
      slide = {content: "content", metadata: slide_metadata}
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1Hcontent\n"
      ].join.inspect)
    end

    it "renders content with disabled global metadata and footer and pager" do
      metadata = build_metadata({
        footer: false,
        pager: false
      })
      slide_metadata = build_slide_metadata({
        footer: {
          text: "slide footer"
        },
        pager: {
          text: "%<page>d of %<total>d"
        }
      })
      slide = {content: "content", metadata: slide_metadata}
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1Hcontent\n",
        "\e[8;1Hslide footer",
        "\e[8;15H1 of 4"
      ].join.inspect)
    end

    it "renders content with global metadata symbols overridden in a slide" do
      metadata = build_metadata({
        footer: "- footer",
        pager: "- %<page>d of %<total>d"
      })
      slide_metadata = build_slide_metadata({
        symbols: {
          base: "ascii",
          override: {
            bullet: "x"
          }
        }
      })
      slide = {content: "- content", metadata: slide_metadata}
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1H\e[33mx\e[0m content\n",
        "\e[8;1H\e[33mx\e[0m footer",
        "\e[8;13H\e[33mx\e[0m 1 of 4"
      ].join.inspect)
    end

    it "renders content with global metadata theme overridden in a slide" do
      metadata = build_metadata({
        footer: "**footer**",
        pager: "*%<page>d of %<total>d*"
      })
      slide_metadata = build_slide_metadata({
        theme: {
          header: %w[magenta underline],
          em: "cyan",
          strong: "green"
        }
      })
      slide = {content: "# content", metadata: slide_metadata}
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)

      expect(renderer.render(slide, 1, 4).inspect).to eq([
        "\e[1;1H\e[35;4mcontent\e[0m\n",
        "\e[8;1H\e[32mfooter\e[0m",
        "\e[8;15H\e[36m1 of 4\e[0m"
      ].join.inspect)
    end
  end

  describe "#clear" do
    it "clears screen" do
      metadata = build_metadata({})
      renderer = described_class.new(converter, ansi, cursor, metadata,
                                     width: 20, height: 8)

      expect(renderer.clear).to eq("\e[2J\e[1;1H")
    end
  end
end
