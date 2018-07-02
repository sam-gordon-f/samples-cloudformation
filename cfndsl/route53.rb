CloudFormation {
	AWSTemplateFormatVersion("2010-09-09")
	Description "Route53 v1"

  Parameter('environmentType') { Type 'String' }
  Parameter('cloudfrontDistributionDomainName') { Type 'String' }

	tagsCommon = [
    { Key: 'environmentType', Value: Ref('environmentType') }
	]

	Resource("route53HostedZoneSample") {
    Type("AWS::Route53::HostedZone")

    Property("Name", "testdomain")
    Property("HostedZoneConfig", {
      "Comment" => "testing hosted zone"
    })
    Property("HostedZoneTags", tagsCommon)
  }

  Resource("route53RecordSetSample") {
		Type('AWS::Route53::RecordSet')

		Property("Comment", "testing record set")
		Property("Name",
			FnJoin("", [
				Ref("environmentType"), ".testdomain."
			])
		)
		Property("Type", "A")
		Property("HostedZoneName", ".testdomain")

		Property("AliasTarget", {
			"DNSName" => Ref("cloudfrontDistributionDomainName"),
			"HostedZoneId" => "Z2FDTNDATAQYW2"
				# when linking to a cf distribution this is a static zone identifier
		})
  }
}
