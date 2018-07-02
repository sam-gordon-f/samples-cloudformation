CloudFormation {
	AWSTemplateFormatVersion("2010-09-09")
	Description "Cloudfront v1"

  Parameter("environmentType") { Type 'String' }
  Parameter("S3BucketSampleArn") { Type 'String' }
  Parameter("S3BucketSampleName") { Type 'String' }

  tagsCommon = [
    { Key: 'environmentType', Value: Ref('environmentType') }
  ]

  Resource("cloudFrontOriginAccessIdentitySample") {
    Type("AWS::CloudFront::CloudFrontOriginAccessIdentity")

    Property("CloudFrontOriginAccessIdentityConfig", {
      "Comment" => "sample S3 origin access identity"
    })
  }

  Resource("cloudFrontDistributionSample") {
    Type("AWS::CloudFront::Distribution")

    Property("DistributionConfig", {
      "Origins" => [{
				"Id" => "S3SampleBucketOrigin",
        "DomainName" => FnJoin("", [Ref("S3BucketSampleName"), ".aws.jbhifi.com.au.s3.amazonaws.com"]),
        "S3OriginConfig" => {
          "OriginAccessIdentity" => FnJoin("", ["origin-access-identity/cloudfront/", Ref("cloudFrontOriginAccessIdentitySample")])
        }
      }],
      "Enabled" => "true",
      "Comment" => "sample bucket cloudfront distribution",
      "DefaultRootObject" => "index.html",
				# redirect all requests to the "bucket root / index.html"
      "Aliases" => [
        FnJoin("", [Ref("environmentType"), ".sampledomain"])
      ],
				# Make sure that you list every route 53 alias to avoid dns highjacking
      "DefaultCacheBehavior" => {
				"DefaultTTL" => 86400,
					# default cache 1 day
        "AllowedMethods" => [
					"GET",
					"HEAD",
					"OPTIONS"
				],
        "TargetOriginId" => "S3SampleBucketOrigin",
        "ForwardedValues" => {
          "QueryString" => true,
          "Cookies" => {
            "Forward" => "none"
          }
        },
        # "ViewerProtocolPolicy" => ""
        "ViewerProtocolPolicy" => "( allow-all | redirect-to-https )"
      },
				# specific cache behaviors
			"CacheBehaviors" => [
				{
					"DefaultTTL" => 300,
					"PathPattern" => "index.html",
					"TargetOriginId" => "S3SampleBucketOrigin",
					"ViewerProtocolPolicy" => "allow-all",
					"ForwardedValues" => {
	          "QueryString" => true,
	          "Cookies" => {
	            "Forward" => "none"
	          }
	        },
				}
			],
			# certificate and WAF reference
			#
      # "ViewerCertificate" => {
      #   "AcmCertificateArn" => FnImportValue(
			# 		FnJoin("", [
			# 			Ref("environmentType"),
			# 			"-jbhifi-aws-config-region-",
			# 			1,
			# 			"-certificate-wildcard"
			# 		])
			# 	),
			# 	"SslSupportMethod" => "sni-only"
      # },
			# "WebACLId" => FnImportValue(
			# 	FnJoin("", [
			# 		Ref("environmentType"),
			# 		"-jbhifi-aws-config-region-",
			# 		Ref("environmentName"),
			# 		"-waf-webacl-web"
			# 	])
			# )
 	  })

    Property("Tags", tagsCommon)
  }

	Resource("S3BucketPolicySample") {
		Type("AWS::S3::BucketPolicy")

		Property("Bucket", Ref("S3BucketSampleName"))
		Property("PolicyDocument", {
      "Statement" => [
				{
					"Effect" => "Allow",
					"Principal" => {
						"AWS" => FnJoin("", ["arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ", Ref("cloudFrontOriginAccessIdentitySample")])
					},
					"Action" => [
						"s3:GetObject"
					],
	    		"Resource" => [
						Ref("S3BucketSampleArn")
					]
      	}
			]
    })
	}

  Output("CloudFrontDistributionDomainNameSample") {
    Value(FnGetAtt("cloudFrontDistributionSample", "DomainName"))
  }
}
