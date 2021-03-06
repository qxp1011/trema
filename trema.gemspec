# encoding: utf-8
$LOAD_PATH.push File.expand_path('../ruby', __FILE__)
require 'trema/version'

Gem::Specification.new do |gem|
  gem.name = 'trema'
  gem.version = Trema::VERSION
  gem.summary = 'Full-stack OpenFlow framework.'
  gem.description = 'Trema is a full-stack, easy-to-use framework for developing OpenFlow controllers in Ruby and C.'

  gem.required_ruby_version = '>= 1.9.3'

  gem.license = 'GPL2'

  gem.authors = ['Yasuhito Takamiya']
  gem.email = ['yasuhito@gmail.com']
  gem.homepage = 'http://github.com/trema/trema'

  gem.executables = %w(trema trema-config)
  gem.files = `git ls-files`.split("\n")

  gem.require_path = 'ruby'
  gem.extensions = ['Rakefile']

  gem.extra_rdoc_files = ['README.md']
  gem.test_files = `git ls-files -- {spec,features}/*`.split("\n")

  gem.add_dependency 'gli', '~> 2.12.2'
  gem.add_dependency 'paper_house', '~> 0.6.2'
  gem.add_dependency 'pio', '~> 0.14.0'
  gem.add_dependency 'rake'
  gem.add_dependency 'rdoc', '~> 4.2.0'

  # Docs
  gem.add_development_dependency 'relish', '~> 0.7.1'
  gem.add_development_dependency 'yard', '~> 0.8.7.6'

  # Guard
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'guard', '~> 2.12.1'
  gem.add_development_dependency 'guard-bundler', '~> 2.1.0'
  gem.add_development_dependency 'guard-rspec', '~> 4.5.0'
  gem.add_development_dependency 'guard-rubocop', '~> 1.2.0'
  gem.add_development_dependency 'pry', '~> 0.10.1'

  # Test
  gem.add_development_dependency 'aruba', '~> 0.6.2'
  gem.add_development_dependency 'codeclimate-test-reporter'
  gem.add_development_dependency 'cucumber', '~> 1.3.18'
  gem.add_development_dependency 'flay', '~> 2.6.1'
  gem.add_development_dependency 'flog', '~> 4.3.2'
  gem.add_development_dependency 'reek', '~> 2.0.0'
  gem.add_development_dependency 'rspec', '~> 3.2.0'
  gem.add_development_dependency 'rubocop', '~> 0.29.0'
end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
