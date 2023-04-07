# frozen_string_literal: true

module CoverRage
  module ForkHook
    def _fork
      pid = super
      CoverRage::Launcher.start if pid.zero?
      pid
    end
  end
end
