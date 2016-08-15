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

end

puts dfn.to_cli_json
