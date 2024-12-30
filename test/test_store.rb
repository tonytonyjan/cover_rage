# frozen_string_literal: true

require 'minitest/autorun'
require 'cover_rage/stores/redis'
require 'cover_rage/stores/sqlite'
require 'cover_rage/stores/pstore'

module TestStore
  module Tests
    def test_no_exception_over_frequently_read_and_write_with_fork_and_threads
      Tempfile.create do |ruby_file|
        ruby_file.write <<~RUBY
          def add_100_times(store)
            100.times do
              store.transaction do
                record = store.list.find { _1.path == 'path' }
                record = record + new_record(execution_count: [1])
                store.update([record])
              end
            end
          end

          def new_record(**)
            CoverRage::Record.new(
              path: 'path',
              revision: '',
              source: 'a = 1',
              execution_count: [0],
              **
            )
          end
          store = CoverRage::Config.store
          store.update([new_record])
          pid = fork
          4.times.map { Thread.new { add_100_times(store) } }.each(&:join)
          exit if pid.nil?

          Process.wait(pid)
          puts store.list.find { _1.path == 'path' }.execution_count.inspect
        RUBY
        ruby_file.close
        env = {
          'COVER_RAGE_STORE_URL' => @store_url,
          'RUBYLIB' => 'lib'
        }
        cmd = ['ruby', '-r', 'cover_rage', ruby_file.path]
        output = IO.popen(env, cmd) do |io|
          io.read.chop
        end
        assert $?.success?
        assert_equal '[800]', output
      end
    end
  end

  class Pstore < Minitest::Test
    parallelize_me!

    def setup
      @db_file = Tempfile.create
      @db_file.close
      @store_url = "pstore:#{@db_file.path}"
    end

    def teardown
      File.unlink(@db_file.path)
    end

    include Tests
  end

  class Sqlite < Minitest::Test
    parallelize_me!

    def setup
      @db_file = Tempfile.create
      @db_file.close
      @store_url = "sqlite:#{@db_file.path}"
    end

    def teardown
      File.unlink(@db_file.path)
    end

    include Tests
  end

  if ENV.key?('TEST_REDIS_URL')
    class Redis < Minitest::Test
      parallelize_me!

      def setup
        @store_url = ENV.fetch('TEST_REDIS_URL')
      end

      include Tests
    end
  end
end
