require 'pry'

sch = schedule do |s|
  s['startAt'] = 'FIRST_ACTIVATION_DATE_TIME'
  s['period'] = '2 Hours'
end
failure = sns_alarm('FailureAlarm') do |f|
  f['topicArn'] = "arn:aws:sns:us-east-1:id:redshift-debug"
  f['subject'] = "RDS to Redshift copy failed"
  f['message'] = "There was a problem executing %{node.name} at for period %{node.@scheduledStartTime} to %{node.@scheduledEndTime}"
end

pipeline_object('Default') do |d|
  d.field('onFail', failure)
  d.field(:schedule, sch)
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
dump_ec2 = ec2_resource('RDSDumpEc2Resource') do |r|
  r.concat(ec2_defaults)
end
load_ec2 = ec2_resource('RedshiftLoadEc2Resource') do |r|
  r.concat(ec2_defaults)
end

redshift_db = redshift_database do |r|
  r['databaseName'] = 'sample'
  r['username'] = 'user'
  r['*password'] = 'pass'
  r['clusterId'] = 'redshift1'
  r['jdbcProperties'] = ['logLevel=2']
end
rds_db = rds_database do |r|
  r['databaseName'] = 'sample'
  r['username'] = 'user'
  r['*password'] = 'pass'
  r['rdsInstanceId'] = 'rds1'
  r['jdbcProperties'] = ['logLevel=2',"zeroDateTimeBehavior=convertToNull", "connectTimeout=0", "socketTimeout=0"]
end

dataf = csv()

first_table = mysql_redshift_copy(
  table_name: 'first',
  rds_db: rds_db,
  rds_runner: dump_ec2,
  redshift_db: redshift_db,
  redshift_runner: load_ec2,
  data_format: dataf,
  s3_base_path: "s3://sample-data/output/"
)

second_table = mysql_redshift_copy(
  table_name: 'second',
  depends_on: first_table,
  rds_depends_on: true
  )

third_table = mysql_redshift_copy(
  table_name: 'three',
  depends_on: second_table,
  rds_depends_on: true
  )
