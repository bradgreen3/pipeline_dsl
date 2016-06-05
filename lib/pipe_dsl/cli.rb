require 'thor'

module PipeDsl
  class CLI < Thor
    class_option :verbose, :type => :boolean

    desc "this is a test", "test it"
    def test
      puts "test"
      d = PipeDsl.definition
    end

  end
end
