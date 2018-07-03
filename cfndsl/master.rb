CloudFormation do
  AWSTemplateFormatVersion '2010-09-09'
  Description 'Master v1'

  Parameter('environmentType') { Type 'String' }
  Parameter('s3BucketSourceUrl') { Type 'String' }

  tags_common = [
    { Key: 'environmentType', Value: Ref('environmentType') }
  ]

  cloudformation_designer_url = 'https://ap-southeast-2.console.aws.amazon.com/cloudformation/designer/home?region=ap-southeast-2&stackId='

  Resource('cloudformationStackSample') do
    Type('AWS::CloudFormation::Stack')

    Property('TemplateURL',
             FnJoin('', [
                      Ref('s3BucketSourceUrl'), 'fileName.json'
                    ]))
    Property('TimeoutInMinutes', 5)
    Property('Parameters',
             'environmentType' => Ref('environmentType'))

    Property('Tags', tags_common)
  end

  Output('CloudFormationStackDesignerUrlSample') do
    Value(FnJoin('', [cloudformation_designer_url.to_s, Ref('cloudformationStackSample')]))
    Description("Designer Url for a sub-stack 'sample'")
  end
end
