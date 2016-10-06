require 'cleanroom'
module PipeDsl
  module CLI
    class Parser < Thor

      desc 'transform DEFINITION', 'Transform the defintion'
      option :format, desc: 'to format' #todo known formats
      def transform(file)
        d = CLI.parse_file(file)

        puts d.to_cli_json
      end


    end
  end
end
