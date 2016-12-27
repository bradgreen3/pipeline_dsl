require 'cleanroom'
require 'hashdiff'

module PipeDsl
  module CLI

    # File parsing utilities
    class Parser < Thor

      desc 'json DEFINITION', 'Transform the defintion to json'
      def json(file)
        d = CLI.parse_file(file)

        puts d.to_cli_json
      end

      desc 'diff FILE1 FILE2', 'Compare (hashdiff) two definition files'
      option :parse_json, desc: 'still parse a .json file'
      # option :strictarray
      def diff(a, b)
        adef = maybe_definition(a)
        bdef = maybe_definition(b)

        diff = HashDiff.best_diff(adef, bdef)
        diff.each do |op, path, value|
          puts " #{op}  #{path} => #{value}"
        end
      end

      private

      def maybe_definition(file)
        str = if File.extname(file) != '.json' || options[:parse_json]
          CLI.parse_file(file).to_cli_json
        else
          File.read(file)
        end
        objs = JSON.parse(str)

        #sort obj arrays
        objs.each do |k, v|
          objs[k].sort_by! { |n| n['id'] } if v.is_a?(Array)
        end

        objs
      end

    end
  end
end
