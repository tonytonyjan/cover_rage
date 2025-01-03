# frozen_string_literal: true

require 'uri'
module CoverRage
  module Config
    def self.path_prefix
      @path_prefix ||= ENV.fetch('COVER_RAGE_PATH_PREFIX', defined?(Rails) && Rails.root ? Rails.root.to_s : Dir.pwd)
    end

    def self.store
      @store ||= begin
        uri = URI.parse(ENV.fetch('COVER_RAGE_STORE_URL', "pstore:#{File.join(Dir.pwd, 'cover_rage.pstore')}"))
        case uri.scheme
        when 'redis', 'rediss'
          require 'cover_rage/stores/redis'
          CoverRage::Stores::Redis.new(uri.to_s)
        when 'sqlite'
          require 'cover_rage/stores/sqlite'
          CoverRage::Stores::Sqlite.new(uri.path)
        when 'pstore'
          require 'cover_rage/stores/pstore'
          CoverRage::Stores::Pstore.new(uri.path)
        else
          raise "Unsupported store: #{uri.scheme}"
        end
      end
    end

    def self.interval
      @interval ||= ENV.fetch('COVER_RAGE_INTERVAL', '60').to_i
    end
  end
end
