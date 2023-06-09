# frozen_string_literal: true

require 'cover_rage/record'
require 'sqlite3'
require 'json'

module CoverRage
  module Stores
    class Sqlite
      def initialize(path)
        @db = SQLite3::Database.new(path)
        @db.execute <<-SQL
          create table if not exists records (
            path text primary key not null,
            revision blob not null,
            source text not null,
            execution_count text not null
          )
        SQL
      end

      def import(records)
        @db.transaction do
          records_to_save = Record.merge(list, records)
          if records_to_save.any?
            @db.execute(
              "insert or replace into records (path, revision, source, execution_count) values #{
                (['(?,?,?,?)'] * records_to_save.length).join(',')
              }",
              records_to_save.each_with_object([]) do |record, memo|
                memo.push(
                  record.path,
                  record.revision,
                  record.source,
                  JSON.dump(record.execution_count)
                )
              end
            )
          end
        end
      end

      def find(path)
        rows = @db.execute(
          'select revision, source, execution_count from records where path = ? limit 1',
          [path]
        )
        return nil if rows.empty?

        revision, source, execution_count = rows.first
        Record.new(
          path: path,
          revision: revision,
          source: source,
          execution_count: JSON.parse(execution_count)
        )
      end

      def list
        @db
          .execute('select path, revision, source, execution_count from records')
          .map! do |(path, revision, source, execution_count)|
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
