$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$SPEC_ROOT = File.dirname(File.expand_path(__FILE__))

require 'pipe_dsl'
require 'awesome_print'
require 'pry'
require 'stringio'
require 'thor'

if ENV['COVERAGE']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

# Set shell to basic
$0 = "thor"
$thor_runner = true
ARGV.clear
Thor::Base.shell = Thor::Shell::Basic

RSpec.configure do |config|
  config.before(:each) do
    ARGV.replace []
    Aws.config[:stub_responses] = true
  end

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  def source_root
    File.join(File.dirname(__FILE__), "fixtures")
  end

  # This code was adapted from Ruby on Rails, available under MIT-LICENSE
  # Copyright (c) 2004-2013 David Heinemeier Hansson
  def silence_warnings
    old_verbose = $VERBOSE
    $VERBOSE = nil
    yield
  ensure
    $VERBOSE = old_verbose
  end

  alias silence capture
end
