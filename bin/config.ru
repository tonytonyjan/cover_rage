# frozen_string_literal: true

require 'cover_rage/viewer'
require 'cover_rage/config'
run CoverRage::Viewer.new(store: CoverRage::Config.store)
