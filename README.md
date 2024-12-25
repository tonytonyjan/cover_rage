![test](https://github.com/tonytonyjan/cover_rage/actions/workflows/test.yml/badge.svg)

# CoverRage

A Ruby production code coverage tool designed to assist you in identifying unused code, offering the following features:

1. easy setup
2. minimal performance overhead
3. minimal external dependencies

![demo](images/demo.png)

## Installation

```shell
gem install cover_rage
```

or

```shell
bundle add cover_rage
```

## Usage

1. Set `COVER_RAGE_STORE_URL` environment variable.
2. Put `require 'cover_rage'` wherever you want to start to record.

### Quick Start

```shell
cat >main.rb <<RUBY
s = 0
10.times do |x|
  s += x
end

if s == 45
  p :ok
else
  p :ng
end
RUBY
gem install cover_rage
export COVER_RAGE_STORE_URL=pstore://$(pwd)/cover_rage.db
ruby -r cover_rage main.rb
cover_rage > report.html
```

### Quick Example for Ruby on Rails

```sh
export COVER_RAGE_STORE_URL=pstore://$(pwd)/cover_rage.db
rails s
```

Rails requires Ruby gems automatically by deafult so we don't need to manually add `require 'cover_rage'`.

To manually start cover_rage, Add `gem 'cover_rage', require: false` to Gemfile and require `cover_rage` explicitly in the code base.

## Export Report

```sh
export COVER_RAGE_STORE_URL=pstore://$(pwd)/cover_rage.db
cover_rage --format html
```

Run `cover_rage -h` for more information.

## Environment Variables

1. `COVER_RAGE_STORE_URL`

   Available URL schemes:

   1. `pstore://ABSOLUTE_PATH_TO_PSTORE_FILE`
   2. `redis://REDIS_HOST`
   3. `sqlite://ABSOLUTE_PATH_TO_SQLITE_DB_FILE`

2. `COVER_RAGE_INTERVAL`

   It sets The interval in seconds between each write to the store. The value should be either an integer or a range in the format `n:m`.

   It is recommended to set a range to avoid write spikes to the store.

   Defaults to `60:90`.

3. `COVER_RAGE_PATH_PREFIX`

   `cover_rage` will only record files that match the specified prefix.

   Defaults to `Rails.root` if the `Rails` constant is defined; otherwise, defaults to `Dir.pwd`.
