<div align="center">
  <img src="https://github.com/piotrmurach/slideck/blob/master/assets/slideck_logo.svg"
       width="360" alt="slideck logo"/>
</div>

# Slideck

[![Gem Version](https://badge.fury.io/rb/slideck.svg)][gem]
[![Actions CI](https://github.com/piotrmurach/slideck/workflows/CI/badge.svg?branch=master)][gh_actions_ci]
[![Build status](https://ci.appveyor.com/api/projects/status/kvlo53t54qimbfqy?svg=true)][appveyor]
[![Maintainability](https://api.codeclimate.com/v1/badges/c96e8367481519c38a06/maintainability)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/piotrmurach/slideck/badge.svg)][coverage]

[gem]: https://badge.fury.io/rb/slideck
[gh_actions_ci]: https://github.com/piotrmurach/slideck/actions?query=workflow%3ACI
[appveyor]: https://ci.appveyor.com/project/piotrmurach/slideck
[codeclimate]:https://codeclimate.com/github/piotrmurach/slideck/maintainability
[coverage]: https://coveralls.io/github/piotrmurach/slideck

> Terminal tool for presenting Markdown-powered slide decks.

## Features

* Write slides in the **Markdown** with extended syntax.
* Show code snippets in [fenced code blocks](https://www.markdownguide.org/extended-syntax/#fenced-code-blocks).
* Syntax highlight code for [over 200 languages](https://github.com/rouge-ruby/rouge/blob/master/docs/Languages.md).
* Create Markdown [tables](https://www.markdownguide.org/extended-syntax/#tables) with advanced formatting.
* [Align](#21-align) slide content with familiar CSS syntax.
* Add [margin](#23-margin) around content for all or a single slide.
* Track progress through the slides with a [pager](#24-pager).
* Display a [footer](#22-footer) at the bottom of every slide.
* Apply custom [symbols](#25-symbols) and style [theme](#26-theme) to content.
* Auto reload presentation when a file with slides changes.

## Installation

**Slideck** will work with any version of Ruby greater than or equal to `2.0`.
Read [Installing Ruby](https://www.ruby-lang.org/en/documentation/installation/)
guide to choose the best installation method.

Once Ruby is set up, install the `slideck` with:

```shell
$ gem install slideck
```

## Contents

* [1. Usage](#1-usage)
* [2. Configuration](#2-configuration)
  * [2.1 align](#21-align)
  * [2.2 footer](#22-footer)
  * [2.3 margin](#23-margin)
  * [2.4 pager](#24-pager)
  * [2.5 symbols](#25-symbols)
  * [2.6 theme](#26-theme)

## 1. Usage

Open a text file and start writing slides in Markdown. Begin the document
by adding configuration for all slides in `YAML` format. Then to denote
a slide, separate its content with three dashes. Use the same configuration
settings to override the global settings for a slide. To do so, specify
settings with `YAML` flow mappings after the slide separator.

Here's a sample of a few slides with global and slide-specific configuration
settings:

````markdown
align: center
margin: 2 5
footer:
  align: center bottom
  text: Footer content

--- margin: 0

# Welcome to Slideck

## Built with TTY Toolkit

--- align: center top

# Code Block

```ruby
puts "Welcome to Slideck"
```

--- theme: {list: magenta}

# Unordered List

- Item 1
- Item 2
- Item 3

--- symbols: ascii

# Table

| A | B | C |
|---|---|---|
| a | b | c |
| a | b | c |
| a | b | c |

--- {pager: false, footer: false}

# The End
````

To start presenting, for example, `slides.md` file in a terminal:

```shell
$ slideck slides.md
```

Use the `-h` or `--help` flag to see help about available presentation
controls and options:

```shell
$ slideck --help
```

Use the `-w` or `--watch` flag to automatically reload the presentation
with any update to the `slides.md` file:

```shell
$ slideck slides.md --watch
```

## 2. Configuration

Configuration options can be global or slide-specific.

Add global configuration options in `YAML` format at the beginning
of a document.

For example, to configure [alignment](#21-align) and [margin](#23-margin)
for all slides:

```markdown
align: center
margin: 2 5

---

First Slide

---

Second Slide

---
```

Use `YAML` flow mappings syntax to change the global configuration for a given
slide. This format is a series of key/value pairs separated by commas and
surrounded by curly braces. The semicolon with space follows a key and splits
it from value. Braces are optional for a single key/value pair.
A slide-specific configuration follows three dashes and needs to be on
the same line.

For example, to override [alignment](#21-align) and [margin](#23-margin)
for a given slide:

```markdown
align: center
margin: 2 5

--- margin: 0

First Slide

--- {align: center top, margin: 1 3}

Second Slide

---
```

### 2.1 Align

**Slideck** draws the slide's content from the left top of the terminal screen
by default. It positions the pager at the bottom right corner. When given, the
footer ends up at the bottom left corner. Use the `:align` configuration to
change the default positioning of content, [footer](#22-footer) and
[pager](#24-pager).

The `align` configuration takes either one or two values. The first value
specifies the horizontal alignment out of `left`, `center` and `right`.
The second value describes vertical alignment out of the `top`, `center`
and `bottom`. Skipping the second value will default the vertical alignment
to the `center`. Use a space, comma or both to separate two values.

For example, to position content at the top center of the screen
on every slide:

```yaml
align: center top
```

Or use shorthand to place content at the center left on every slide:

```yaml
align: left
```

Use the same configuration to change the alignment for a single slide. It
needs to follow after the slide separator and be on the same line.

For example, to place a given slide at the bottom left:

```yaml
--- align: left bottom
```

### 2.2 Footer

**Slideck** doesn't show the footer by default. Use the `:footer` configuration
to add content to the bottom left of the screen for every slide.

For example, to display a footer on every slide:

```yaml
footer: Footer content
```

The footer supports `Markdown` syntax:

```yaml
footer: **bold** content
```

The footer can also span more than one line:

```yaml
footer: "first line\nsecond line\nthird line"
```

Use the `:align` key to change the footer alignment and the `:text` key
to specify its content.

For example, to specify a global footer at the bottom center of every slide:

```yaml
footer:
  align: center bottom
  text: Footer content
```

Use the same configuration to change the footer for a single slide. It needs
to follow after the slide separator and be on the same line.

For example, to place a footer at the bottom center of the screen:

```yaml
--- footer: {align: center bottom, text: Footer content}
```

Or, use a `false` value to hide a footer for a single slide:

```yaml
--- footer: false
```

### 2.3 Margin

The `margin` specifies a distance from all four sides of the terminal screen.
It follows CSS rules and can have one, two, three or four integer values. Use
a space or comma to separate each integer value.

The following are all possible ways to specify a margin:

```yaml
margin: 1         # the same margin of 1 for all sides
margin: 1 2       # 1 to the top and bottom, and 2 to the left and right
margin: 1 2 3     # 1 to the top, 2 to the left and right, and 3 to the bottom
margin: 1 2 3 4   # 1 to the top, 2 to the right, 3 to the bottom, 4 to the left
```

Or, specify a margin with explicit side names:

```yaml
margin:
  top: 1
  right: 2
  bottom: 3
  left: 4
```

Like shorthand notation, specify names only for the configured sides.

For example, to add only the top margin and leave all the other sides with
their default values:

```yaml
margin:
  top: 1
```

Use the same configuration to change the margin for a single slide. It needs
to follow after the slide separator and be on the same line.

For example, to zero out the margin for a given slide:

```yaml
--- margin: 0
```

### 2.4 Pager

**Slideck** displays the `pager` in the bottom right corner of the terminal
screen. The display format is `%<page>d / %<total>d`, where the first
placeholder represents the current slide and the second is the total
number of slides.

For example, to change the pager display:

```yaml
pager: "Page %<page>d of %<total>d"
```

The pager supports `Markdown` syntax:

```yaml
pager: "**Bold** %<total> pages"
```

The pager can also span more than one line:

```yaml
pager: "Page\n%<page>d\nof\n%<total>d"
```

Use the `:align` key to change the pager alignment and the `:text` key
to specify its content.

For example, to place the pager at the bottom center of every slide:

```yaml
pager:
  align: center bottom
  text: "Page %<page>d of %<total>d"
```

Or, use a `false` value to hide a pager on all slides:

```yaml
pager: false
```

Use the same configuration to change the pager for a single slide. It needs
to follow after the slide separator and be on the same line.

For example, to place a pager at the bottom center of a given slide:

```yaml
--- pager: {align: center bottom, text: "Page %<page>d of %<total>d"}
```

Or, use a `false` value to hide a pager for a single slide:

```yaml
--- pager: false
```

### 2.5 Symbols

**Slideck** decorates `Markdown` elements with `unicode` symbols by default.
Use the `:symbols` configuration to change the display of decorative
characters. It takes either a single value or key/value pairs. The single
value specifies a character set out of `ascii` or `unicode`. The key/value
pairs accept the `:base` and `:override` keys. Like a single value,
the `:base` key takes either `ascii` or `unicode`.

For example, to change the default symbols for all slides to `ascii`:

```yaml
symbols: ascii
```

Or, use the `:base` key to specify the `ascii` character set:

```yaml
symbols:
  base: ascii
```

The `:override` key accepts key/value pairs, where the key is a symbol name
and the value is a decorative character. Please see the
[tty-markdown](https://github.com/piotrmurach/tty-markdown#24-symbols)
for a complete list of symbols.

For example, to change the `:bullet` symbol for every slide:

```yaml
symbols:
  override:
    bullet: x
```

Use the same configuration to change the symbols for a single slide. It needs
to follow after the slide separator and be on the same line.

For example, to change a character set to `ascii` for a single slide:

```yaml
--- symbols: ascii
```

Or, to change the `:bullet` symbol for a single slide:

```yaml
--- symbols: {override: {bullet: x}}
```

### 2.6 Theme

**Slideck** displays `Markdown` elements with a default style theme. Use
the `:theme` configuration to change individual element styles. It takes
key/value pairs where the key is the element name, and the value is a single
style or list of styles. Please see the
[tty-markdown](https://github.com/piotrmurach/tty-markdown#22-theme)
for a complete list of element names and their styles.

For example, to change `em`, `link` and `list` element styles for every slide:

```yaml
theme:
  em: blue
  link: cyan
  list: magenta
```

Use the same configuration to change the theme for a single slide. It needs
to follow after the slide separator and be on the same line.

For example, to change `em`, `link` and `list` element styles for
a single slide:

```yaml
--- theme: {em: blue, link: cyan, list: magenta}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests. You can also run `bin/console`
for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/piotrmurach/slideck. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [code of conduct](https://github.com/piotrmurach/slideck/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the
[GNU Affero General Public License v3.0](https://opensource.org/licenses/AGPL-3.0).

## Code of Conduct

Everyone interacting in the Slideck project's codebases, issue trackers, chat
rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/piotrmurach/slideck/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2022 Piotr Murach. See [LICENSE.txt](LICENSE.txt) for further
details.
