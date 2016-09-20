# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rbfiler/version'

Gem::Specification.new do |spec|
  spec.name          = 'rbfiler'
  spec.version       = Rbfiler::VERSION
  spec.authors       = ['yuusuke12dec']
  spec.email         = ['yuusuke12dec@gmail.com']

  spec.summary       = %q{CUI filer implemented by Ruby}
  spec.description   = %q{CUI filer implemented by Ruby. Good old filer.}
  spec.homepage      = 'https://github.com/yuusuke12dec/rbfiler'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = ['rbfiler']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
