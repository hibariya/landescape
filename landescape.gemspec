# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'landescape/version'

Gem::Specification.new do |spec|
  spec.name          = 'landescape'
  spec.version       = Landescape::VERSION
  spec.authors       = %w(hibariya)
  spec.email         = %w(celluloid.key@gmail.com)
  spec.description   = %(A library for handling escape sequence)
  spec.summary       = %(Handle escape sequence)
  spec.homepage      = 'https://github.com/hibariya/landescape'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib examples)

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
