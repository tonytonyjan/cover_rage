# frozen_string_literal: true

require 'cover_rage/config'
require 'cover_rage/record'
require 'digest'

module CoverRage
  class Recorder
    attr_reader :store

    def initialize(path_prefix:, store:)
      @store = store
      @path_prefix = path_prefix.end_with?('/') ? path_prefix : "#{path_prefix}/"
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
        interval = Config.interval
        jitter = 0.15
        loop do
          sleep(interval + rand * interval * jitter)
          save(Coverage.result(stop: false, clear: true))
        end
      end
    end

    def save(coverage_result)
      records = []
      coverage_result.map do |filepath, execution_count|
        filepath = File.expand_path(filepath) unless filepath.start_with?('/')
        next unless filepath.start_with?(@path_prefix)
        next if execution_count.all? { _1.nil? || _1.zero? }

        relative_path = filepath.delete_prefix(@path_prefix)
        revision, source = read_file_with_revision(filepath)

        records << Record.new(
          path: relative_path,
          revision: revision,
          source: source,
          execution_count: execution_count
        )
      end
      if records.any?
        @store.transaction do
          records_to_save = Record.merge(@store.list, records)
          @store.update(records_to_save)
        end
      end
    end

    private

    def read_file_with_revision(path)
      return @file_cache[path] if @file_cache.key?(path)

      @file_cache[path] = begin
        content = File.read(path)
        [@digest.hexdigest(content), content]
      end
    end
  end
end
