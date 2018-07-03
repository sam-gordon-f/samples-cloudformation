CloudFormation do
  AWSTemplateFormatVersion('2010-09-09')
  Description 'elasticSearch v1'

  Parameter('environmentType') { Type 'String' }

  Resource("cloudWatchDashboardSample") do
    Type('AWS::CloudWatch::Dashboard')

    Property('DashboardName', FnJoin('', [Ref('environmentType'), '-api_gateway_name']))
    Property('DashboardBody',
             FnSub(
               '{' \
                 '"widgets" : [' \
                 '{' \
                   '"type" : "metric",' \
                   '"x" : 0,' \
                   '"y" : 0,' \
                   '"width" : 6,' \
                   '"height" : 6,' \
                   '"properties" : {' \
                     '"view" : "timeSeries",' \
                     '"stacked" : false,' \
                     '"metrics" : [' \
                       '[ "AWS/ApiGateway", "Count", "ApiName", "api_gateway_name", { "stat" : "Sum" } ],' \
                       '[ ".", "4XXError", ".", ".", { "stat" : "Sum" } ],' \
                       '[ ".", "5XXError", ".", ".", { "stat" : "Sum" } ]' \
                     '],' \
                     '"region" : "${stackRegion}",' \
                     '"title" : "${environmentType}-api_gateway_name' \
                   '}' \
                 '}' \
                 ']' \
               '}',
               'environmentType' => Ref('environmentType'),
               'stackRegion' => Ref('AWS::Region')
             ))
  end
end
