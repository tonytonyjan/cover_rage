# frozen_string_literal: true

require 'cover_rage/record'
require 'pstore'

module CoverRage
  module Stores
    class Pstore
      def initialize(path)
        @store = PStore.new(path, true)
      end

      def import(records)
        @store.transaction do
          persisted_records = @store.keys.map { @store[_1] }
          records_to_save = Record.merge(persisted_records, records)
          records_to_save.each { @store[_1.path] = _1 }
        end
      end

      def list
        @store.transaction do
          @store.keys.map { @store[_1] }
        end
      end

      def clear
        @store.transaction do
          @store.keys.each { @store.delete(_1) }
        end
      end
    end
  end
end
