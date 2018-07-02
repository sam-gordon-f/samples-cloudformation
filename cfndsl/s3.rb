CloudFormation {
	AWSTemplateFormatVersion("2010-09-09")
	Description "S3Bucket v1"

	Parameter("environmentType") { Type 'String' }

	tagsCommon = [
    { Key: 'environmentType', Value: Ref('environmentType') }
	]

	Resource("S3BucketSample") {
		Type("AWS::S3::Bucket")

		Property("AccessControl", "Private")
		Property("BucketName", FnJoin("", [Ref("environmentType"), "-sample-bucket"]))

		Property('Tags', tagsCommon)
	}

	Output("S3BucketSampleName") {
    Description("Name of Hosting S3 bucket")
		Value(Ref("S3BucketSample"))
	}

	Output("S3BucketSampleArn") {
		Description("ARN of Hosting S3 bucket")
		Value(FnJoin("", ["arn:aws:s3:::", Ref("S3BucketSample")]))
	}

	Output("S3BucketSampleDomainName") {
		Description("DomainName of S3 bucket")
		Value(FnGetAtt("S3BucketSample", "DomainName"))
	}
}
