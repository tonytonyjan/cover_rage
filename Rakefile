# frozen_string_literal: true

require 'rubygems/package_task'

spec = Gem::Specification.load("#{__dir__}/cover_rage.gemspec")
Gem::PackageTask.new(spec).define

require 'rake/testtask'
Rake::TestTask.new

task default: :test
