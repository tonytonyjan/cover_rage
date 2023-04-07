# CoverRage

## Prerequisite Ruby Gems

- `sqlite3`
- `redis`
- `rackup`

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

### Quick Example

```shell
cat >foo.rb <<RUBY
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
gem install cover_rage sqlite3 rackup
export COVER_RAGE_STORE_URL=sqlite://$(pwd)/mydb
ruby -r cover_rage foo.rb
cover_rage -p 8080
# open http://localhost:8080
```

### Quick Example for Ruby on Rails

```sh
COVER_RAGE_STORE_URL=sqlite://$(pwd)/cover_rage.db rails s
```

Rails requires Ruby gems automatically by deafult so we don't need to manually add `require 'cover_rage'`.

To manually start cover_rage, Add `gem 'cover_rage', require: false` to Gemfile and require `cover_rage` explicitly in the code base.

## Viewer Server

Use the command `cover_rage` to start a viewer server.

Run `cover_rage -h` for more information.

## Configuration

1. `COVER_RAGE_STORE_URL`

   Available URL schemes:

   1. `redis://REDIS_HOST`
   2. `sqlite://ABSOLUTE_PATH_TO_SQLITE_DB_FILE`

2. `COVE_RAGE_SLEEP_DURATION`

   Defaults to `60:90`.

   `COVE_RAGE_SLEEP_DURATION` sets the seconds between each write to the store.

   The value should be either an integer or a range in the format `n:m`.

   By default `cover_rage` randomly sleeps from 60 to 90 seconds before each write to the store in order to solve the issue like [cache stampede](https://en.wikipedia.org/wiki/Cache_stampede). This approaches is called probabilistic early expiration.

3. `COVE_RAGE_ROOT_PATH`

   Defaults to `Rails.root` if `Rails` is defined, otherwise, defaults to `Dir.pwd`.

   `COVE_RAGE_ROOT_PATH` sets project root path. `cover_rage` only records files in the root path.
