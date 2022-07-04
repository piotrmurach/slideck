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

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add slideck

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install slideck

## Usage

To start presenting `slides.md` in a terminal, run:

```shell
$ slideck slides.md
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/piotrmurach/slideck. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/piotrmurach/slideck/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [GNU Affero General Public License v3.0](https://opensource.org/licenses/AGPL-3.0).

## Code of Conduct

Everyone interacting in the Slideck project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/piotrmurach/slideck/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2022 Piotr Murach. See [LICENSE.txt](LICENSE.txt) for further details.
