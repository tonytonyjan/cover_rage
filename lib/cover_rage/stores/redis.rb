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
            ::Redis.new(url:, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
          else
            ::Redis.new(url:)
          end
      end

      def transaction(&)
        loop do
          break if @redis.watch(KEY) do
            @redis.multi do |multi|
              Thread.current[:redis_multi] = multi
              yield
            ensure
              Thread.current[:redis_multi] = nil
            end
          end
        end
      end

      def update(records)
        arguments = []
        records.each do |record|
          arguments.push(record.path, JSON.dump(record.to_h))
        end

        client = Thread.current[:redis_multi] || @redis
        client.hset(KEY, *arguments)
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
