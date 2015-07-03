# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pipe_dsl/version'

Gem::Specification.new do |spec|
  spec.name          = "pipe_dsl"
  spec.version       = PipeDsl::VERSION
  spec.authors       = ["Justin Hart"]
  spec.email         = ["jhart@onyxraven.com"]

  spec.summary       = %q{A DSL for generating and managing AWS Datapipeline definitions}
  spec.description   = %q{A DSL and code for generating datapipeline definitions, and commands for uploading and managing datapipeline in AWS}
  spec.homepage      = "https://github.com/Ibotta/pipe_dsl"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'aws-sdk-resources', '~> 2'
  spec.add_dependency 'json'

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  #explode pry-plus into pieces
  spec.add_development_dependency 'bond'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'pry-doc'
  spec.add_development_dependency 'pry-docmore'
  spec.add_development_dependency 'pry-stack_explorer'
  spec.add_development_dependency 'pry-rescue'
  spec.add_development_dependency "awesome_print"
  #end explode pry-plus
end
