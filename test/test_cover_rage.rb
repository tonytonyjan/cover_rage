# frozen_string_literal: true

require 'minitest/autorun'
require 'json'

module TestCoverRage
  module Tests
    def test_simple
      assert_report([1, 1, 10, nil, 1, 1, nil, 0, nil], <<~RUBY)
        s = 0
        10.times do |x|
          s += x
        end
        if s == 45
          a = :ok
        else
          a = :ng
        end
      RUBY
    end

    def test_fork
      assert_report([1, 2], <<~RUBY)
        fork
        a = 1
      RUBY
    end

    def test_daemon
      assert_report([1, 1], <<~RUBY)
        Process.daemon
        a = 1
      RUBY
    end

    def test_simple_long_live
      assert_report_long_live([1, 1, 10, nil, 1, 1, nil, 0, nil], <<~RUBY)
        s = 0
        10.times do |x|
          s += x
        end
        if s == 45
          a = :ok
        else
          a = :ng
        end
      RUBY
    end

    def test_fork_long_live
      assert_report_long_live([1, 2], <<~RUBY)
        fork
        a = 1
      RUBY
    end

    def test_daemon_long_live
      assert_report_long_live([1, 1], <<~RUBY)
        Process.daemon
        a = 1
      RUBY
    end

    private

    def assert_report(expected, ruby_source)
      Tempfile.create do |ruby_file|
        ruby_file.write ruby_source
        ruby_file.close

        env = {
          'COVER_RAGE_STORE_URL' => @store_url,
          'COVER_RAGE_PATH_PREFIX' => File.dirname(ruby_file.path),
          'RUBYLIB' => 'lib'
        }
        cmd = ['ruby', '-r', 'cover_rage', ruby_file.path]
        system(env, *cmd, exception: true)
        IO.popen(env, ['bin/cover_rage', '-f', 'json']) do |io|
          item = JSON.parse(io.read).find { ruby_file.path.end_with?(_1['path']) }
          assert_equal expected, item['execution_count']
        end
      end
    end

    def assert_report_long_live(expected, ruby_source)
      Tempfile.create do |ruby_file|
        ruby_file.write ruby_source
        ruby_file.close

        Tempfile.create do |main_file|
          main_file.write <<~RUBY
            load '#{ruby_file.path}'
            sleep 2
          RUBY
          main_file.close
          env = {
            'COVER_RAGE_STORE_URL' => @store_url,
            'COVER_RAGE_PATH_PREFIX' => File.dirname(ruby_file.path),
            'COVER_RAGE_INTERVAL' => '1',
            'RUBYLIB' => 'lib'
          }
          system(env, 'ruby', '-r', 'cover_rage', main_file.path, exception: true)
          sleep 1.5 # wait for the thread to save coverage results
          IO.popen(env, ['bin/cover_rage', '-f', 'json']) do |io|
            item = JSON.parse(io.read).find { ruby_file.path.end_with?(_1['path']) }
            assert_equal expected, item['execution_count']
          end
        end
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
