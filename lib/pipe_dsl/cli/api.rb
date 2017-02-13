module PipeDsl
  module CLI
    # AWS api methods
    class Api < Thor

      desc 'create NAME', 'Create this pipeline in AWS'
      option :unique_id, desc: 'Custom unique ID for pipeline'
      def create(name)
        unique_id = options[:unique_id] || "#{name}_#{Time.now.strftime('%Y%m%d%H%M%S')}"

        puts "creating #{name}" if options[:verbose]
        new_pipe = client.create_pipeline(
          name: name,
          unique_id: unique_id
        )
        pipeline_id = begin
          new_pipe.pipeline_id
        rescue
          raise Thor::Error, "Error: No ID: #{name}"
        end

        puts "#{name} @ #{pipeline_id}"
        new_pipe
      end

      desc 'upload DEFINITION', 'Upload the pipeline definition to AWS'
      option :pipeline_id, desc: 'Pipeline ID'
      option :name, desc: 'Pipeline name (finds ID automatically)'
      def upload(file)
        definition = CLI.parse_file(file)
        pipeline_id = options[:pipeline_id] || find_pipeline_id(options[:name])
        raise Thor::Error, "A Pipeline ID is required" unless pipeline_id

        puts "uploading definition on #{pipeline_id}" if options[:verbose]
        result = client.put_pipeline_definition(
          pipeline_id: pipeline_id,
          pipeline_objects: definition.pipeline_objects,
          parameter_objects: definition.parameter_objects,
          parameter_values: definition.parameter_values
        )

        if result && result.errored
          validation_result_error(result)
        elsif result && !result.validation_warnings.empty?
          validation_result_warnings(result)
        end

        result
      end

      desc 'activate', 'Activate the pipeline in AWS'
      option :pipeline_id, desc: 'Pipeline ID'
      option :name, desc: 'Pipeline name (finds ID automatically)'
      def activate
        pipeline_id = options[:pipeline_id] || find_pipeline_id(options[:name])
        raise Thor::Error, "A Pipeline ID is required" unless pipeline_id

        puts "activating #{pipeline_id}"
        client.activate_pipeline(pipeline_id: pipeline_id)
      end

      desc 'delete', 'Delete the pipeline in AWS'
      option :pipeline_id, desc: 'Pipeline ID'
      option :name, desc: 'Pipeline name (finds ID automatically)'
      def delete
        pipeline_id = options[:pipeline_id] || find_pipeline_id(options[:name])
        raise Thor::Error, "A Pipeline ID is required" unless pipeline_id

        puts "deleting #{pipeline_id}"
        client.delete_pipeline(pipeline_id: pipeline_id)
      end

      desc 'validate DEFINITION', 'Validate a definition file'
      option :pipeline_id, desc: 'Pipeline ID'
      def validate(file)
        definition = CLI.parse_file(file)

        pipeline_id = options[:pipeline_id] || find_pipeline_id(options[:name])
        raise Thor::Error, "A Pipeline ID is required" unless pipeline_id

        puts "validating definition on #{pipeline_id}" if options[:verbose]
        result = client.validate_pipeline_definition(
          pipeline_id: pipeline_id,
          pipeline_objects: definition.pipeline_objects,
          parameter_objects: definition.parameter_objects,
          parameter_values: definition.parameter_values
        )

        if result && result.errored
          validation_result_error(result)
        elsif result && !result.validation_warnings.empty?
          validation_result_warnings(result)
        else
          puts "Validation passed"
        end

        result
      end

      desc 'execute NAME DEFINITION', 'Execute (create, upload and activate) a definition'
      option :activate, type: :boolean, desc: 'Activate after upload', default: true
      def execute(name, file)
        options[:pipeline_id] = find_pipeline_id(name)
        delete if options[:pipeline_id]

        options[:pipeline_id] = create(name).pipeline_id
        upload(file)
        activate if options[:activate]
      end

      private

      # datapipeline client
      def client
        @client ||= Aws::DataPipeline::Client.new
      end

      #find a pipeline id from a name
      def find_pipeline_id(name)
        pipe = client.list_pipelines.pipeline_id_list.find { |i| i.name == name }
        pipe.id if pipe
      end

      #print out a error result
      def validation_result_error(result)
        error_string = ''
        result.validation_errors.each do |o|
          error_string << "\t * #{o.id}:\n"
          o.errors.each do |e|
            error_string << "\t\t * #{e}\n"
          end
        end
        raise Thor::Error, "Validation Failure:\n#{error_string}"
      end

      #warnings output from pipeline result
      def validation_result_warnings(result)
        error_string = "Warnings:\n"
        result.validation_warnings.each do |o|
          error_string << "\t * #{o.id}:\n"
          o.warnings.each do |e|
            error_string << "\t\t * #{e}\n"
          end
        end
        puts error_string
      end

    end
  end
end
