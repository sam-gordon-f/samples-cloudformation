CloudFormation do
  AWSTemplateFormatVersion('2010-09-09')
  Description 'Lambda v1'

  Parameter('environmentType') do
    Type 'String'
  end

  Parameter('s3BucketNameCodeLocation') do
    Type 'String'
  end

  tags_common = [{
    Key: 'environmentType',
    Value: Ref('environmentType')
  }]

  lambda_details = {
    'Sample' => {
      'runTime' => 'nodejs6.10',
      'handler' => 'handler',
      'handlerFile' => 'Sample',
      'codeDirectory' => 'Sample',
      'memory' => 256,
      'envParams' => {
        'sampleEnvParam' => 'sampleEnvValue'
      },
      'allowedInvokers' => [
        'lambda.amazonaws.com',
        'logs.amazonaws.com'
      ]
    }
  }

  lambda_details.each do |k, v|
    i = 1
    v['allowedInvokers'].each do |v2|
      Resource("LambdaPermission#{k}#{i}") do
        Type('AWS::Lambda::Permission')

        Property('FunctionName', FnGetAtt("LambdaFunction#{k}", 'Arn'))
        Property('Action', 'lambda:InvokeFunction')
        Property('Principal', v2)
        Property('SourceAccount', Ref('AWS::AccountId'))
      end

      i += 1
    end

    Resource("IAMRole#{k}") do
      Type('AWS::IAM::Role')
    end

    Resource("IAMPolicy#{k}") do
      Type('AWS::IAM::Policy')

      Property('PolicyName',
               FnJoin('',
                      [
                        Ref('environmentType'),
                        '-sample-policy'
                      ]))
      Property('Roles', [
                 Ref("IAMRole#{k}")
               ])
    end

    Resource("LambdaFunction#{k}") do
      Type('AWS::Lambda::Function')

      Property('FunctionName',
               FnJoin('', [
                        Ref('environmentType'),
                        "-#{k}"
                      ]))
      Property('Handler', "#{v['handlerFile']}.#{v['handler']}")
      Property('Role', Ref("IAMRole#{k}"))
      Property('MemorySize', v['memory'])
      Property('TracingConfig',
               'Mode' => 'Active')

      Property('Code',
               'S3Bucket' => Ref('s3BucketNameCodeLocation'),
               'S3Key' => "codeFolder/#{v['codeDirectory']}.zip")

      Property('Runtime', v['runTime'])
      Property('Timeout', 25)
      Property('Tags', tags_common)
    end
    #
    # Resource("LogsLogGroup#{k}") do
    #   Type('AWS::Logs::LogGroup')
    #
    #   Property('LogGroupName',
    #            FnJoin('', [
    #                     '/aws/lambda/',
    #                     Ref("LambdaFunction#{k}")
    #                   ]))
    #   Property('RetentionInDays', 30)
    # end

    # Output("LambdaFunctionName#{k}") do
    #     Description('Lambda Function Name')
    #   Value(Ref(k))
    # Export(FnJoin('', [Ref('environmentType'), "-#{applicationName}-", Ref('environmentName'), "-lambda-name-#{k}"]))
    # end
    #
    # Output("LambdaFunctionArn#{k}") do
    #     Description('Lambda function ARN')
    #   Value(FnGetAtt(k, 'Arn'))
    # Export(FnJoin('', [Ref('environmentType'), "-#{applicationName}-", Ref('environmentName'), "-lambda-arn-#{k}"]))
    # end
    # end
    #
    # Resource('SubscriptionFilterS3Export') do
    #     Type('AWS::Logs::SubscriptionFilter')
    #
    #   Property('DestinationArn', FnJoin('', ['arn:aws:lambda:', Ref('AWS::Region'), ':', Ref('AWS::AccountId'), ':function:', Ref('environmentType'), '-jbhifi-logs-', Ref('environmentName'), '-logsToElasticSearch']))
    # Property('FilterPattern', '[timestamp=*Z, request_id="*-*", application="*-*", severity<5, message]')
    # Property('LogGroupName', FnJoin('', ['/aws/lambda/', Ref('elasticSearchIndexToS3')]))
    #
    # DependsOn([
    #   'elasticSearchIndexToS3'
    # ])
    # end
    #
    # Resource('MetricFilterLogCreateSuccess') do
    #     Type('AWS::Logs::MetricFilter')
    #
    #   Property('LogGroupName', FnJoin('', ['/aws/lambda/', Ref('logsToElasticSearch')]))
    # Property('FilterPattern', FnJoin('', ['[timestamp=*Z, request_id="*-*", cwMetricCheck="CLOUDWATCH_METRIC_LOG_CREATE_SUCCESS", size="*"]']))
    # Property('MetricTransformations', [{
    #   'MetricValue' => '$size',
    #   'MetricNamespace' => FnJoin('', ['CloudServices/', Ref('environmentType'), "-#{applicationName}-", Ref('environmentName')]),
    #   'MetricName' => 'log-create-success'
    # }])
    #
    # DependsOn([
    #   'logsToElasticSearch'
    # ])
    # end
    #
    # Resource('MetricFilterLogCreateFailure') do
    #     Type('AWS::Logs::MetricFilter')
    #
    #   Property('LogGroupName', FnJoin('', ['/aws/lambda/', Ref('logsToElasticSearch')]))
    # Property('FilterPattern', FnJoin('', ['[timestamp=*Z, request_id="*-*", cwMetricCheck="CLOUDWATCH_METRIC_LOG_CREATE_FAILURE", size="*"]']))
    # Property('MetricTransformations', [{
    #   'MetricValue' => '$size',
    #   'MetricNamespace' => FnJoin('', ['CloudServices/', Ref('environmentType'), "-#{applicationName}-", Ref('environmentName')]),
    #   'MetricName' => 'log-create-failure'
    # }])
    #
    # DependsOn([
    #   'logsToElasticSearch'
    # ])
  end
end
