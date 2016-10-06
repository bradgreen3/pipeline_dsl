require_relative '../cli'
require 'thor/version'

#load subcommands
Dir["#{File.dirname(__FILE__)}/*.rb"].each { |f| require f }

module PipeDsl
  module CLI
    # base command set for executable
    class Base < Thor
      class_option :verbose, type: :boolean, desc: 'Verbose output', aliases: '-v'

      desc 'api SUBCOMMAND ...ARGS', 'AWS api commands'
      subcommand 'api', Api

      desc 'parser SUBCOMMAND ...ARGS', 'parser commands'
      subcommand 'parser', Parser

      desc 'version', 'Get the version'
      def version
        puts "#{self.class} #{VERSION}"
        puts "ruby: #{RUBY_VERSION} thor: #{Thor::VERSION}" if options[:verbose]
      end
    end
  end
end
