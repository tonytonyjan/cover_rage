# frozen_string_literal: true

require 'cover_rage/config'
require 'cover_rage/record'
require 'digest'

module CoverRage
  class Recorder
    SLEEP_DURATION = Config.sleep_duration
    attr_reader :store

    def initialize(root_path:, store:)
      @store = store
      @root_path = root_path.end_with?('/') ? root_path : "#{root_path}/"
      @digest = Digest::MD5.new
      @file_cache = {}
    end

    def start
      return if @thread&.alive?

      unless Coverage.running?
        Coverage.start
        at_exit { save(Coverage.result) }
      end
      @thread = Thread.new do
        loop do
          sleep(rand(SLEEP_DURATION))
          save(Coverage.result(stop: false, clear: true))
        end
      end
    end

    private

    def save(coverage_result)
      records = []
      coverage_result.map do |filepath, execution_count|
        filepath = File.expand_path(filepath) unless filepath.start_with?('/')
        next unless filepath.start_with?(@root_path)
        next if execution_count.all? { _1.nil? || _1.zero? }

        relative_path = filepath.delete_prefix(@root_path)
        revision, source = read_file_with_revision(filepath)

        records << Record.new(
          path: relative_path,
          revision: revision,
          source: source,
          execution_count: execution_count
        )
      end
      @store.import(records) if records.any?
    end

    def read_file_with_revision(path)
      return @file_cache[path] if @file_cache.key?(path)

      @file_cache[path] = begin
        content = File.read(path)
        [@digest.hexdigest(content), content]
      end
    end
  end
end
