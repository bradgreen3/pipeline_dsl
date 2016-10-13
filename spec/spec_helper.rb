$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$SPEC_ROOT = File.dirname(File.expand_path(__FILE__))

require 'pipe_dsl'
require 'awesome_print'
require 'pry'

if ENV['COVERAGE']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end
