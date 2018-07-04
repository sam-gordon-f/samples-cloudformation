CloudFormation do
  AWSTemplateFormatVersion('2010-09-09')
  Description 'acm v1'

  Parameter('environmentType') { Type 'String' }
  Mapping('template_config', template_config)

  tags_common = [
    { Key: 'environmentType', Value: Ref('environmentType') }
  ]

  Resource('certificateManagerCertificateSample') do
    Type('AWS::CertificateManager::Certificate')

    Property('DomainName', FnJoin('', ['*.', Ref('environmentType'), '.sampledomain']))
    Property('DomainValidationOptions', [
               {
                 'DomainName' => FnFindInMap('template_config', 'acm', 'certificate_domain'),
                 'ValidationDomain' => FnFindInMap('template_config', 'acm', 'certificate_verfication_domain')
               }
             ])
    Property('Tags', tags_common)
  end

  Output('CertificateManagerCertificateSample') do
    Description('wildcard certificate for *.envType.sampledomain')
    Value(Ref('certificateManagerCertificateSample'))
  end
end
