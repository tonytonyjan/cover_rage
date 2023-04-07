# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'cover_rage'
  spec.version = '0.0.1'
  spec.authors = 'Weihang Jian'
  spec.email = 'tonytonyjan@gmail.com'
  spec.summary = 'coverage recorder'
  spec.description = 'coverage recorder'
  spec.homepage = 'https://github.com/tonytonyjan/cover_rage'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.3.0'
  spec.files = Dir['lib/**/*.{rb,erb}', 'bin/config.ru']
  spec.executables = ['cover_rage']
  spec.add_development_dependency 'rake', '~> 13.0'
end
