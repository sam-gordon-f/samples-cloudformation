CloudFormation do
  AWSTemplateFormatVersion('2010-09-09')
  Description 'Cloudfront v1'

  Parameter('environmentType') { Type 'String' }
  Parameter('S3BucketSampleArn') { Type 'String' }
  Parameter('S3BucketSampleName') { Type 'String' }
  Parameter('WAFACLArn') { Type 'String' }
  Parameter('ACMCertificateArn') { Type 'String' }

  tags_common = [
    { Key: 'environmentType', Value: Ref('environmentType') }
  ]

  Resource('cloudFrontOriginAccessIdentitySample') do
    Type('AWS::CloudFront::CloudFrontOriginAccessIdentity')

    Property('CloudFrontOriginAccessIdentityConfig',
             'Comment' => 'sample S3 origin access identity')
  end

  Resource('cloudFrontDistributionSample') do
    Type('AWS::CloudFront::Distribution')

    Property('DistributionConfig',
             'Origins' => [{
               'Id' => 'S3SampleBucketOrigin',
               'DomainName' => FnJoin(
                 '', [
                   Ref('environmentType'), '.sampledomain'
                 ]
               ),
               'S3OriginConfig' => {
                 'OriginAccessIdentity' => FnJoin('', ['origin-access-identity/cloudfront/', Ref('cloudFrontOriginAccessIdentitySample')])
               }
             }],
             'Enabled' => 'true',
             'Comment' => 'sample bucket cloudfront distribution',
             'DefaultRootObject' => 'index.html',
             # redirect all requests to the "bucket root / index.html"
             'Aliases' => [
               FnJoin('', [Ref('environmentType'), '.sampledomain'])
             ],
             # Make sure that you list every route 53 alias to avoid dns highjacking
             'DefaultCacheBehavior' => {
               'DefaultTTL' => 86_400,
               # default cache 1 day
               'AllowedMethods' => %w[
                 GET
                 HEAD
                 OPTIONS
               ],
               'TargetOriginId' => 'S3SampleBucketOrigin',
               'ForwardedValues' => {
                 'QueryString' => true,
                 'Cookies' => {
                   'Forward' => 'none'
                 }
               },
               # "ViewerProtocolPolicy" => ""
               'ViewerProtocolPolicy' => '( allow-all | redirect-to-https )'
             },
             # specific cache behaviors
             'CacheBehaviors' => [
               {
                 'DefaultTTL' => 300,
                 'PathPattern' => 'index.html',
                 'TargetOriginId' => 'S3SampleBucketOrigin',
                 'ViewerProtocolPolicy' => 'allow-all',
                 'ForwardedValues' => {
                   'QueryString' => true,
                   'Cookies' => {
                     'Forward' => 'none'
                   }
                 }
               }
             ],

             'ViewerCertificate' => {
               'AcmCertificateArn' => Ref('ACMCertificateArn'),
               'SslSupportMethod' => 'sni-only'
             },
             'WebACLId' => Ref('WAFACLArn'))

    Property('Tags', tags_common)
  end

  Resource('S3BucketPolicySample') do
    Type('AWS::S3::BucketPolicy')

    Property('Bucket', Ref('S3BucketSampleName'))
    Property('PolicyDocument',
             'Statement' => [
               {
                 'Effect' => 'Allow',
                 'Principal' => {
                   'AWS' => FnJoin('', [
                                     'arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ',
                                     Ref('cloudFrontOriginAccessIdentitySample')
                                   ])
                 },
                 'Action' => [
                   's3:GetObject'
                 ],
                 'Resource' => [
                   Ref('S3BucketSampleArn')
                 ]
               }
             ])
  end

  Output('CloudFrontDistributionDomainNameSample') do
    Value(FnGetAtt('cloudFrontDistributionSample', 'DomainName'))
  end
end
