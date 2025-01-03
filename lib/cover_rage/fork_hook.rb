# frozen_string_literal: true

module CoverRage
  module ForkHook
    def _fork
      pid = super
      CoverRage::Launcher.start if pid.zero?
      pid
    end

    def daemon(...)
      CoverRage::Launcher.recorder.save(Coverage.result(stop: false))
      returned = super
      CoverRage::Launcher.start
      returned
    end
  end
end
