# frozen_string_literal: true

module CoverRage
  Record = Data.define(:path, :revision, :source, :execution_count) do
    def self.merge(existing, current)
      records_to_save = []
      current.each do |record|
        found = existing.find { _1.path == record.path }
        records_to_save <<
          if found.nil? || record.revision != found.revision
            record
          else
            record + found
          end
      end
      records_to_save
    end

    def +(other)
      with(
        execution_count: execution_count.map.with_index do |item, index|
          item.nil? ? nil : item + other.execution_count[index]
        end
      )
    end
  end
end
