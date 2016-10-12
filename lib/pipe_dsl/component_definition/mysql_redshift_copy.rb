require_relative '../component_definition'
module PipeDsl
  #common components for datapipeline
  class MysqlRedshiftCopy < ComponentDefinition

    attr_accessor :table_name, :data_format, :s3_base_path, :select_query, :retries
    attr_accessor :rds_db, :rds_runner, :rds_depends_on, :rds_copy
    attr_accessor :redshift_db, :redshift_runner, :redshift_depends_on, :redshift_copy

    #init
    # @param [String] table_name
    def initialize(table_name:, depends_on: nil, rds_db: nil, rds_runner: nil, redshift_db: nil, redshift_runner: nil, data_format: nil, s3_base_path: nil, select_query: nil, rds_depends_on: nil, redshift_depends_on: nil, retries: nil, &block)

      raise ArgumentError, "depends_on must be a #{self.class}" if depends_on && !depends_on.is_a?(self.class)

      # use or copy all the parameters
      @rds_db = rds_db || (depends_on && depends_on.rds_db)
      @rds_runner = rds_runner || (depends_on && depends_on.rds_runner)
      @redshift_db = redshift_db || (depends_on && depends_on.redshift_db)
      @redshift_runner = redshift_runner || (depends_on && depends_on.redshift_runner)
      @data_format = data_format || (depends_on && depends_on.data_format)
      @s3_base_path = s3_base_path || (depends_on && depends_on.s3_base_path)
      #TODO: validate these?

      @retries = retries || (depends_on && depends_on.retries) || 1

      @select_query = select_query

      @rds_depends_on = if rds_depends_on == true
        depends_on.rds_copy
      else
        rds_depends_on
      end

      @redshift_depends_on = if redshift_depends_on == true
        depends_on.redshift_copy
      else
        redshift_depends_on
      end

      super(pipeline_objects:[], parameter_objects: [], parameter_values: [], &block)

      build_definition(table_name: table_name)
    end

    private

    #build the definition based on givens
    def build_definition(table_name:)
      rds_table = pipeline_object(type: "MySqlDataNode", id: "#{table_name}MySqlDataNodeObject") do |m|
        m['database'] = rds_db
        m['table'] = table_name
        m['selectQuery'] = select_query || "SELECT * from %{table} where updated_at > '%{format(minusHours(@scheduledStartTime,48),'YYYY-MM-dd hh:mm:ss')}'"
      end

      s3 = pipeline_object(type: "S3DataNode", id: "#{table_name}S3DataNodeObject") do |s|
        s['filePath'] = "#{s3_base_path}/#{table_name}/%{@scheduledStartTime}.csv.gz"
        s['dataFormat'] = data_format
        s['compression'] = 'GZIP'
      end

      redshift_table = pipeline_object(type: "RedshiftDataNode", id: "#{table_name}RedshiftDataNodeObject") do |r|
        r['database'] = redshift_db
        r['tableName'] = table_name
      end

      @rds_copy = pipeline_object(type: "CopyActivity", id: "#{table_name}RdsToS3CopyActivity") do |c|
        c['runsOn'] = rds_runner
        c['maximumRetries'] = retries
        c['input'] = rds_table
        c['output'] = s3
        c['dependsOn'] = rds_depends_on if rds_depends_on
      end

      @redshift_copy = pipeline_object(type: "RedshiftCopyActivity", id: "#{table_name}S3ToRedshiftCopyActivity") do |c|
        c['runsOn'] = redshift_runner
        c['maximumRetries'] = retries
        c['input'] = s3
        c['output'] = redshift_table
        c['dependsOn'] = redshift_depends_on if redshift_depends_on
      end
    end

  end
end
