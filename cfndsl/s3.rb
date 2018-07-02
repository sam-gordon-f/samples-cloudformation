CloudFormation do
  AWSTemplateFormatVersion('2010-09-09')
  Description 'S3Bucket v1'

  Parameter('environmentType') { Type 'String' }

  tags_common = [
    { Key: 'environmentType', Value: Ref('environmentType') }
  ]

  Resource('S3BucketSample') do
    Type('AWS::S3::Bucket')

    Property('AccessControl', 'Private')
    Property('BucketName',
             FnJoin('', [
                      Ref('environmentType'),
                      '-sample-bucket'
                    ]))

    Property('Tags', tags_common)
  end

  Output('S3BucketSampleName') do
    Description('Name of Hosting S3 bucket')
    Value(Ref('S3BucketSample'))
  end

  Output('S3BucketSampleArn') do
    Description('ARN of Hosting S3 bucket')
    Value(FnJoin('', ['arn:aws:s3:::', Ref('S3BucketSample')]))
  end

  Output('S3BucketSampleDomainName') do
    Description('DomainName of S3 bucket')
    Value(FnGetAtt('S3BucketSample', 'DomainName'))
  end
end
