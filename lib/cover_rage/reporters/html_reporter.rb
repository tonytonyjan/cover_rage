# frozen_string_literal: true

require 'erb'
require 'json'

module CoverRage
  module Reporters
    class HtmlReporter
      def report(records)
        records = JSON.dump(records.map(&:to_h))
        ERB.new(File.read("#{__dir__}/html_reporter/index.html.erb")).result(binding)
      end
    end
  end
end
