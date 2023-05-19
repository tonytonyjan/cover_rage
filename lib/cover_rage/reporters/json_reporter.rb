# frozen_string_literal: true

require 'json'

module CoverRage
  module Reporters
    class JsonReporter
      def report(records)
        JSON.dump(records.map(&:to_h))
      end
    end
  end
end
