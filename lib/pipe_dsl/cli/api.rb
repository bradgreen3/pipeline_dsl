module PipeDsl
  module CLI
    # AWS api methods
    class Api < Thor

      # datapipeline client
      def client
        @client ||= Aws::DataPipeline::Client.new
      end

      desc 'create name', 'Create this pipeline in AWS'
      def create(name)
        puts "creating #{name}" if options[:verbose]
        new_pipe = client.create_pipeline(
          name: name,
          unique_id: "#{name}_#{Time.now.strftime('%Y%m%d%H%M%S')}"
        )
        pipeline_id = begin
          new_pipe.pipeline_id
        rescue
          raise Thor::Error, "Error: No ID: #{name}"
        end

        puts "#{name} @ #{pipeline_id}"
        new_pipe
      end

      desc 'upload', 'Upload the pipeline to AWS'
      def upload
      end

      desc 'activate', 'Activate the pipeline in AWS'
      def activate
      end

      desc 'delete', 'Delete the pipeline in AWS'
      def delete
      end

    end
  end
end
