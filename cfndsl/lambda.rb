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

  template_config['lambda'].each do |k, _v|
    # iterate and create lambda invoke permissions for each service principal specified
    template_config['lambda'][k]['lambda_invokers'].each do |k2, _v2|
      Resource("LambdaPermission#{k}#{k2}") do
        Type('AWS::Lambda::Permission')

        Property('FunctionName', FnGetAtt("LambdaFunction#{k}", 'Arn'))
        Property('Action', 'lambda:InvokeFunction')
        Property('Principal', k2)
        Property('SourceAccount', Ref('AWS::AccountId'))
      end
    end

    # create a role for the function to invoke with
    Resource("IAMRole#{k}") do
      Type('AWS::IAM::Role')
    end

    # iterate through all of the specified permissions for the role
    template_config['lambda'][k]['lambda_permissions'].each do |k3, _v3|
      Resource("IAMPolicy#{k3}") do
        Type('AWS::IAM::Policy')

        Property('PolicyName', FnJoin('', [Ref('environmentType'), "-sample-policy-#{k3}"]))
        Property('Roles', [
                   Ref("IAMRole#{k}")
                 ])
      end
    end

    # define lambda function for the current iteration
    Resource("LambdaFunction#{k}") do
      Type('AWS::Lambda::Function')

      Property('Handler', "#{template_config['lambda'][k]['handlerFile']}.#{template_config['lambda'][k]['handler']}")
      Property('Role', Ref("IAMRole#{k}"))
      Property('MemorySize', template_config['lambda'][k]['memory'])
      Property('TracingConfig',
               'Mode' => 'Active')

      Property('Code',
               'S3Bucket' => Ref('s3BucketNameCodeLocation'),
               'S3Key' => template_config['lambda'][k]['codeLocation'])

      Property('Runtime', template_config['lambda'][k]['runtime'])
      Property('Timeout', template_config['lambda'][k]['timeout'])
      Property('Tags', tags_common)
    end

    Resource("LogsLogGroup#{k}") do
      Type('AWS::Logs::LogGroup')

      Property('LogGroupName',
               FnJoin('', [
                        '/aws/lambda/',
                        Ref("LambdaFunction#{k}")
                      ]))
      Property('RetentionInDays', template_config['lambda'][k]['timeout'])
    end

    # @TODO - add index check to see if the yml specifies this
    Resource("LogsSubscriptionFilter#{k}") do
      Type('AWS::Logs::SubscriptionFilter')

      Property('DestinationArn', template_config['lambda'][k]['subscriptions']['filters']['filter_1']['destination'])
      Property('FilterPattern', template_config['lambda'][k]['subscriptions']['filters']['filter_1']['pattern'])
      Property('LogGroupName', FnJoin('', ['/aws/lambda/', Ref("LambdaFunction#{k}")]))

      DependsOn([
                  "LogsLogGroup#{k}"
                ])
    end

    # @TODO - add index check to see if the yml specifies this
    Resource("LogsMetricFilter#{k}") do
      Type('AWS::Logs::MetricFilter')

      Property('LogGroupName', FnJoin('', ['/aws/lambda/', Ref("LambdaFunction#{k}")]))
      Property('FilterPattern', template_config['lambda'][k]['subscriptions']['metrics']['metric_1']['pattern'])
      Property('MetricTransformations', [{
                 'MetricValue' => '$size',
                 'MetricNamespace' => FnJoin('', ['customNameSpace/', "sampleMetric#{k}"]),
                 'MetricName' => template_config['lambda'][k]['subscriptions']['metrics']['metric_1']['metricName']
               }])

      DependsOn([
                  "LogsLogGroup#{k}"
                ])
    end
  end
end
