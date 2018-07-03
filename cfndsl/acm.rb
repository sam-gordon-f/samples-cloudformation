CloudFormation do
  AWSTemplateFormatVersion('2010-09-09')
  Description 'acm v1'

  Parameter('environmentType') { Type 'String' }

  tags_common = [
    { Key: 'environmentType', Value: Ref('environmentType') }
  ]

  Resource('certificateManagerCertificateSample') do
    Type('AWS::CertificateManager::Certificate')

    Property('DomainName', FnJoin('', ['*.', Ref('environmentType'), '.sampledomain']))
    Property('DomainValidationOptions', [
               {
                 'DomainName' => FnJoin('', ['*.', Ref('environmentType'), '.sampledomain']),
                 'ValidationDomain' => 'sampledomain'
               }
             ])
    Property('Tags', tags_common)
  end

  Output('CertificateManagerCertificateSample') do
    Description('wildcard certificate for *.envType.sampledomain')
    Value(Ref('certificateManagerCertificateSample'))
  end
end
