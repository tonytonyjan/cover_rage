# frozen_string_literal: true

require 'uri'
module CoverRage
  module Config
    def self.root_path
      @root_path ||= ENV.fetch('COVER_RAGE_ROOT_PATH', defined?(Rails) && Rails.root ? Rails.root.to_s : Dir.pwd)
    end

    def self.store
      @store ||= begin
        uri = URI.parse(ENV.fetch('COVER_RAGE_STORE_URL'))
        case uri.scheme
        when 'redis'
          require 'cover_rage/stores/redis'
          CoverRage::Stores::Redis.new(uri.to_s)
        when 'sqlite'
          require 'cover_rage/stores/sqlite'
          CoverRage::Stores::Sqlite.new(uri.path)
        end
      end
    end

    def self.sleep_duration
      @sleep_duration ||= begin
        args =
          ENV.fetch('COVER_RAGE_SLEEP_DURATION', '60:90').split(':').map!(&:to_i).first(2)
        args.push(args.first.succ) if args.length < 2
        Range.new(*args, true)
      end
    end

    def self.disable?
      @disable ||= ENV.key?('COVER_RAGE_DISABLE')
    end
  end
end
