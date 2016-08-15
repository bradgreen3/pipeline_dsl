require 'thor'
require_relative '../pipe_dsl'

module PipeDsl
  class CLI < Thor

  #   class_option :verbose, :type => :boolean

    desc "version", "Get the version"
    def version
      puts "#{self.class.to_s} #{VERSION}"
    end

    desc "convert FILE", 'Convert a file'
    def convert(fn)

    end

  end
end
