# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'cover_rage'
  spec.version = '1.0.0'
  spec.authors = 'Weihang Jian'
  spec.email = 'tonytonyjan@gmail.com'
  spec.summary = 'cover_rage is a Ruby code coverage tool designed to be simple and easy to use. It can be used not only for test coverage but also in production services to identify unused code.'
  spec.description = <<~DESC
    cover_rage is a Ruby code coverage tool designed to be simple and easy to use. It can be used not only for test coverage but also in production services to identify unused code.

    Key features:

    1. Runs in continuous processes (e.g., Rails servers)
    2. Zero dependencies
    3. Supports forking and daemonization without additional setup
  DESC
  spec.homepage = 'https://github.com/tonytonyjan/cover_rage'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2'
  spec.files = Dir['lib/**/*']
  spec.executables = ['cover_rage']
  spec.add_development_dependency 'minitest', '~> 5.18'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'redis', '~> 5.3'
  spec.add_development_dependency 'sqlite3', '~> 2.5'
end
