# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_force/version'

Gem::Specification.new do |spec|
  spec.name          = "active_force"
  spec.version       = ActiveForce::VERSION
  spec.authors       = ["Eloy Espinaco", "Pablo Oldani", "Armando Andini", "José Piccioni"]
  spec.email         = "eloyesp@gmail.com"
  spec.description   = %q{Use SalesForce as an ActiveModel}
  spec.summary       = %q{Help you implement models persisting on Sales Force within Rails using RESTForce}
  spec.homepage      = "https://github.com/ionia-corporation/active_force"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 2.0'

  spec.add_dependency 'active_attr', '~> 0.8'
  spec.add_dependency 'restforce',   '~> 1.4'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '>= 0'
  spec.add_development_dependency 'rspec', '>= 0'
  spec.add_development_dependency 'pry', '>= 0'
end
