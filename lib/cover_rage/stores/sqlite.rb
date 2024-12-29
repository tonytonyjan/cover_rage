# frozen_string_literal: true

require 'cover_rage/record'
require 'sqlite3'
require 'json'

module CoverRage
  module Stores
    class Sqlite
      def initialize(path)
        @mutex = Mutex.new
        @path = path
        @db = SQLite3::Database.new(path)
        @db.execute <<-SQL
          create table if not exists records (
            path text primary key not null,
            revision blob not null,
            source text not null,
            execution_count text not null
          )
        SQL
        process_ext = Module.new
        process_ext.module_exec(self) do |store|
          define_method :_fork do
            store.instance_variable_get(:@db).close
            pid = super()
            store.instance_variable_set(:@db, SQLite3::Database.new(path))
            pid
          end
        end
        Process.singleton_class.prepend(process_ext)
      end

      def transaction(&)
        @mutex.synchronize do
          @db.transaction(:exclusive, &)
        rescue SQLite3::BusyException
          retry
        end
      end

      def update(records)
        @db.execute(
          "insert or replace into records (path, revision, source, execution_count) values #{
            (['(?,?,?,?)'] * records.length).join(',')
          }",
          records.each_with_object([]) do |record, memo|
            memo.push(
              record.path,
              record.revision,
              record.source,
              JSON.dump(record.execution_count)
            )
          end
        )
      end

      def list
        @db
          .execute('select path, revision, source, execution_count from records')
          .map do |(path, revision, source, execution_count)|
            Record.new(
              path: path,
              revision: revision,
              source: source,
              execution_count: JSON.parse(execution_count)
            )
          end
      end

      def clear
        @db.execute('delete from records')
      end
    end
  end
end
