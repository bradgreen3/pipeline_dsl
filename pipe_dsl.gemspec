# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'pipe_dsl/version'

Gem::Specification.new do |spec|
  spec.name          = "pipe_dsl"
  spec.version       = PipeDsl::VERSION
  spec.authors       = ["Justin Hart"]
  spec.email         = ["jhart@onyxraven.com"]

  spec.summary       = %q{A composable ruby DSL for the AWS DataPipeline}
  spec.description   = %q{A DSL for building components and entire definitions for the AWS Datapipeline}
  spec.homepage      = "https://github.com/Ibotta/pipeline_dsl"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'aws-sdk-resources', '~> 2'
  spec.add_dependency 'json', '~> 1.8'
  spec.add_dependency 'thor', '~> 0.19'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  #explode pry-plus into pieces
  spec.add_development_dependency 'bond'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'pry-doc'
  spec.add_development_dependency 'pry-docmore'
  spec.add_development_dependency 'pry-stack_explorer'
  spec.add_development_dependency 'pry-rescue'
  spec.add_development_dependency 'awesome_print'
  #end explode pry-plus

  #try out pipely
  spec.add_development_dependency "pipely"
  spec.add_development_dependency "activesupport", '< 5'

end
