# frozen_string_literal: true

require 'cover_rage/record'
require 'erb'
require 'json'

module CoverRage
  class Viewer
    LAYOUT_PAGE = ERB.new(File.read("#{__dir__}/viewer/layout.erb"))
    INDEX_PAGE = ERB.new(File.read("#{__dir__}/viewer/index.erb"))
    FILE_PAGE = ERB.new(File.read("#{__dir__}/viewer/file.erb"))

    class Item
      attr_reader(
        :path,
        :execution_count,
        :number_of_lines,
        :number_of_hits,
        :number_of_misses,
        :number_of_relevancies,
        :coverage
      )

      def initialize(record)
        @path = record.path
        @execution_count = record.execution_count
        @number_of_lines = record.execution_count.length
        @number_of_hits = record.execution_count.count { _1&.positive? }
        @number_of_misses = record.execution_count.count { _1&.zero? }
        @number_of_relevancies = record.execution_count.count { !_1.nil? }
        @coverage = @number_of_hits.to_f / @number_of_relevancies
      end
    end

    def initialize(store:)
      @store = store
    end

    def call(env)
      template =
        case env['PATH_INFO']
        when '/'
          items =
            @store
            .list
            .map! { Item.new(_1) }
            .sort! do |a, b|
              next -1 if b.coverage.nan?
              next 1 if a.coverage.nan?

              a.coverage <=> b.coverage
            end
          INDEX_PAGE
        when '/file'
          path = URI.decode_www_form(env['QUERY_STRING']).assoc('path').last

          record = @store.find(path)
          return [404, {}, []] if record.nil?

          source_code = record.source
          execution_count = JSON.dump(record.execution_count)
          FILE_PAGE
        when '/clear'
          return [405, {}, []] unless env['REQUEST_METHOD'] == 'DELETE'

          @store.clear
          return [302, { 'location' => '/' }, []]
        else return [404, {}, []]
        end
      body = layout { template.result(binding) }
      [200, {}, [body]]
    end

    private

    def layout
      LAYOUT_PAGE.result(binding)
    end
  end
end
