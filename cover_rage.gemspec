# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'cover_rage'
  spec.version = '0.0.6'
  spec.authors = 'Weihang Jian'
  spec.email = 'tonytonyjan@gmail.com'
  spec.summary = 'A Ruby production code coverage tool'
  spec.description = <<~DESC
    A Ruby production code coverage tool designed to assist you in identifying unused code, offering the following features:

    1. easy setup
    2. minimal performance overhead
    3. minimal external dependencies
  DESC
  spec.homepage = 'https://github.com/tonytonyjan/cover_rage'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.3.0'
  spec.files = Dir['lib/**/*']
  spec.executables = ['cover_rage']
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'minitest', '~> 5.18'
end
