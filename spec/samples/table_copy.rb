def rds_to_redshift(rds_db:, rds_runner:, redshift_db:, redshift_runner:, table:, data_format:,s3_base_path:, select_query:nil, rds_depends_on:nil, redshift_depends_on:nil)

  rds_copy = nil
  redshift_copy = nil

  dfn = PipeDsl.definition do |dfn|
    s3 = dfn.pipeline_object(type: "S3DataNode", id: "#{table}S3DataNodeObject") do |s|
      s['filePath'] = "#{s3_base_path}/#{table}/%{@scheduledStartTime}.csv.gz"
      s['dataFormat'] = data_format
      s['compression'] = 'GZIP'
    end
    rds_table = dfn.pipeline_object(type: "MySqlDataNode", id: "#{table}MySqlDataNodeObject") do |m|
      m['database'] = rds_db
      m['table'] = table
      m['selectQuery'] = select_query || "SELECT * from %{table} where updated_at > '%{format(minusHours(@scheduledStartTime,48),'YYYY-MM-dd hh:mm:ss')}'"
    end
    redshift_table = dfn.pipeline_object(type: "RedshiftDataNode", id: "#{table}RedshiftDataNodeObject") do |r|
      r['database'] = redshift_db
      r['tableName'] = table
    end

    rds_copy = dfn.pipeline_object(type: "CopyActivity", id: "#{table}RdsToS3Activity") do |c|
      c['runsOn'] = rds_runner
      c['maximumRetries'] = 1
      c['input'] = rds_table
      c['output'] = s3
      c['dependsOn'] = rds_depends_on if rds_depends_on
    end
    redshift_copy = dfn.pipeline_object(type: "RedshiftCopyActivity", id: "#{table}S3ToRedshiftActivity") do |c|
      c['runsOn'] = redshift_runner
      c['maximumRetries'] = 1
      c['input'] = s3
      c['output'] = redshift_table
      c['dependsOn'] = redshift_depends_on if redshift_depends_on
    end
  end

  [dfn, rds_copy, redshift_copy]
end


dfn = PipeDsl.definition do |dfn|
  sch = dfn.pipeline_object('Schedule') do |s|
    s['startAt'] = 'FIRST_ACTIVATION_DATE_TIME'
    s['period'] = '2 Hours'
  end
  failure = dfn.pipeline_object(id: 'FailureAlarm', type: 'SnsAlarm') do |f|
    f['topicArn'] = "arn:aws:sns:us-east-1:id:redshift-debug"
    f['subject'] = "RDS to Redshift copy failed"
    f['message'] = "There was a problem executing %{node.name} at for period %{node.@scheduledStartTime} to %{node.@scheduledEndTime}"
  end

  dfn.pipeline_object('Default') do |d|
    d.ref('onFail', failure)
    d.ref(:schedule, sch)
    d.concat({
               "failureAndRerunMode" => "CASCADE",
               "scheduleType" => "cron",
               "role" => "DataPipelineDefaultRole",
               "resourceRole" => "DataPipelineDefaultResourceRole",
               "pipelineLogUri" => "s3://sample-logs/data_pipeline_logs/sample/"
    })
  end

  ec2_defaults = {
    "terminateAfter" => "4 Hours",
    "securityGroups" => "sample_data_pipeline",
    "maximumRetries" => "1",
    "maxActiveInstances" => "1",
    "logUri" => "s3://sample-logs/data_pipeline_logs/sample/%{type}/%{name}",
  }
  dump_ec2 = dfn.pipeline_object(id: 'RDSDumpEc2Resource', type: 'Ec2Resource') do |r|
    r.concat(ec2_defaults)
  end
  load_ec2 = dfn.pipeline_object(id: 'RedshiftLoadEc2Resource', type: 'Ec2Resource') do |r|
    r.concat(ec2_defaults)
  end

  redshift_db = dfn.pipeline_object('RedshiftDatabase') do |r|
    r['databaseName'] = 'sample'
    r['username'] = 'user'
    r['*password'] = 'pass'
    r['clusterId'] = 'redshift1'
    r['jdbcProperties'] = ['logLevel=2']
  end
  rds_db = dfn.pipeline_object('RdsDatabase') do |r|
    r['databaseName'] = 'sample'
    r['username'] = 'user'
    r['*password'] = 'pass'
    r['rdsInstanceId'] = 'rds1'
    r['jdbcProperties'] = ['logLevel=2',"zeroDateTimeBehavior=convertToNull", "connectTimeout=0", "socketTimeout=0"]
  end

  dataf = dfn.pipeline_object(id: "DataFormat", type: "CSV")

  first_dfn, first_rds, first_redshift = rds_to_redshift(
    rds_db: rds_db,
    rds_runner: dump_ec2,
    redshift_db: redshift_db,
    redshift_runner: load_ec2,
    table: 'first',
    data_format: dataf,
    s3_base_path: "s3://sample-data/output/"
  )
  dfn.concat(first_dfn)
  second_dfn, second_rds, second_redshift = rds_to_redshift(
    rds_db: rds_db,
    rds_runner: dump_ec2,
    redshift_db: redshift_db,
    redshift_runner: load_ec2,
    table: 'second',
    data_format: dataf,
    s3_base_path: "s3://sample-data/output/",
    rds_depends_on: first_rds
  )
  dfn.concat(second_dfn)
  third_dfn, third_rds, third_redshift = rds_to_redshift(
    rds_db: rds_db,
    rds_runner: dump_ec2,
    redshift_db: redshift_db,
    redshift_runner: load_ec2,
    table: 'three',
    data_format: dataf,
    s3_base_path: "s3://sample-data/output/",
    rds_depends_on: second_rds
  )
  dfn.concat(third_dfn)

end

puts dfn.to_cli_json
