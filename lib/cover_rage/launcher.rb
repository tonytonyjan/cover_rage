# frozen_string_literal: true

require 'cover_rage/recorder'
require 'cover_rage/config'
require 'cover_rage/fork_hook'
require 'coverage'

module CoverRage
  class Launcher
    singleton_class.attr_reader :recorder

    def self.start(**kwargs)
      if @recorder.nil?
        @recorder = CoverRage::Recorder.new(
          store: CoverRage::Config.store,
          path_prefix: CoverRage::Config.path_prefix,
          **kwargs
        )
      end
      @recorder.start
      return unless Process.respond_to?(:_fork)
      return if Process.singleton_class < CoverRage::ForkHook

      Process.singleton_class.prepend(CoverRage::ForkHook)
    end
  end
end
