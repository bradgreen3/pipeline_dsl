# PipeDsl

[![Build Status](https://travis-ci.com/Ibotta/pipeline_dsl.svg?token=p3cwTFx7ToZtzJ6tLUid&branch=master)](https://travis-ci.com/Ibotta/pipeline_dsl) [![Code Climate](https://codeclimate.com/repos/57ffbcd69a61e94f2f002cd8/badges/1e454b2d835817f63388/gpa.svg)](https://codeclimate.com/repos/57ffbcd69a61e94f2f002cd8/feed) [![Test Coverage](https://codeclimate.com/repos/57ffbcd69a61e94f2f002cd8/badges/1e454b2d835817f63388/coverage.svg)](https://codeclimate.com/repos/57ffbcd69a61e94f2f002cd8/coverage)

This gem provides a wrapper DSL and CLI tools for managing AWS DataPipeline definitions.

Typically DataPipeline definitions are managed through lengthy, repetitive JSON files.  The goal of this project is to provide a reusable interface to generating definitions, and a heplful wrapper around the most common API operations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pipe_dsl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pipe_dsl

## Usage

### Ruby API

### CLI

## TODO

* [x] Base object DSL
* [x] Basic API operations
* [x] Reusable component framework
* [ ] Simpler/cleaner DSL (per type/component registration)
* [ ] High code coverage

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pipe_dsl. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

