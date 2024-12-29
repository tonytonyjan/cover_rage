# frozen_string_literal: true

require 'cover_rage/record'
require 'pstore'

module CoverRage
  module Stores
    class Pstore
      def initialize(path)
        @store = PStore.new(path, true)
      end

      def transaction
        @store.transaction do
          @transaction = true
          yield
        ensure
          @transaction = false
        end
      end

      def update(records)
        if @transaction
          records.each { @store[_1.path] = _1 }
        else
          @store.transaction do
            records.each { @store[_1.path] = _1 }
          end
        end
      end

      def list
        if @transaction
          @store.keys.map { @store[_1] }
        else
          @store.transaction do
            @store.keys.map { @store[_1] }
          end
        end
      end

      def clear
        if @transaction
          @store.keys.each { @store.delete(_1) }
        else
          @store.transaction do
            @store.keys.each { @store.delete(_1) }
          end
        end
      end
    end
  end
end
