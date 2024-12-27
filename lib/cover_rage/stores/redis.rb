# frozen_string_literal: true

require 'cover_rage/record'
require 'redis'
require 'json'
require 'openssl'

module CoverRage
  module Stores
    class Redis
      KEY = 'cover_rage_records'
      def initialize(url)
        @redis =
          if url.start_with?('rediss')
            ::Redis.new(url: url, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
          else
            ::Redis.new(url: url)
          end
      end

      def import(records)
        loop do
          break if @redis.watch(KEY) do
            records_to_save = Record.merge(list, records)
            arguments = []
            records_to_save.each do |record|
              arguments.push(record.path, JSON.dump(record.to_h))
            end
            @redis.multi { _1.hset(KEY, *arguments) }
          end
        end
      end

      def find(path)
        result = @redis.hget(KEY, path)
        return nil if result.nil?

        Record.new(**JSON.parse(result))
      end

      def list
        result = @redis.hgetall(KEY)
        return [] if result.empty?

        result.map { |_, value| Record.new(**JSON.parse(value)) }
      end

      def clear
        @redis.del(KEY)
      end
    end
  end
end
