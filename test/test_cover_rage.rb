# frozen_string_literal: true

require 'minitest/autorun'
require 'json'

class TestCoverRage < Minitest::Test
  parallelize_me!

  def test_thread_keep_working_after_fork
    Tempfile.create do |ruby_file|
      ruby_file.write <<~RUBY
        pid = fork
        sleep
      RUBY
      ruby_file.close

      Tempfile.create do |db_file|
        db_file.close
        env = {
          'COVER_RAGE_STORE_URL' => "pstore:#{db_file.path}",
          'COVER_RAGE_ROOT_PATH' => File.dirname(ruby_file.path),
          'COVER_RAGE_SLEEP_DURATION' => '1',
          'RUBYLIB' => 'lib'
        }
        cmd = ['ruby', '-r', 'cover_rage', ruby_file.path]
        pid = spawn(env, *cmd)
        sleep 1.1 # wait for the thread to save coverage results
        IO.popen(env, ['bin/cover_rage', '-f', 'json']) do |io|
          assert_equal [1, 2], JSON.parse(io.read).dig(0, 'execution_count')
        end
        Process.kill 'TERM', pid
      end
    end
  end
end
