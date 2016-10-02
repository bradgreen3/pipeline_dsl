require_relative '../cli'
require_relative 'api'
require 'thor/version'

module PipeDsl
  module CLI
    # base command set for executable
    class Base < Thor
      class_option :verbose, type: :boolean, desc: 'Verbose output', aliases: '-v'

      desc 'api SUBCOMMAND ...ARGS', 'AWS api commands'
      subcommand 'api', Api

      desc 'version', 'Get the version'
      def version
        puts "#{self.class} #{VERSION}"
        puts "ruby: #{RUBY_VERSION} thor: #{Thor::VERSION}" if options[:verbose]
      end
    end
  end
end
