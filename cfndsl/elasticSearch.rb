CloudFormation do
  AWSTemplateFormatVersion('2010-09-09')
  Description 'elasticSearch v1'

  Parameter('environmentType') { Type 'String' }

  tags_common = [
    { Key: 'environmentType', Value: Ref('environmentType') }
  ]

  elastic_search_version = '5.5'
  elastic_search_options = {
    'rest.action.multi.allow_explicit_index' => 'true',
    'indices.fielddata.cache.size' => ''
  }
  elastic_search_policy =
    {
      'Version' => '2012-10-17',
      'Statement' => [
        {
          'Sid' => '',
          'Effect' => 'Allow',
          'Principal' => {
            'AWS' => '*'
          },
          'Action' => [
            'es:ESHttpPost',
            'es:ESHttpGet'
          ],
          'Condition' => {
            'IpAddress' => {
              'aws:SourceIp' => [
                '10.10.10.1/32'
                # white listed to only 10.10.10.1
              ]
            }
          },
          'Resource' => FnJoin(
            '', [
              'arn:aws:es:',
              Ref('AWS::Region'),
              ':',
              Ref('AWS::AccountId'),
              ':domain/*/*'
            ]
          )
        }
      ]
    }

  Resource('elasticSearchDomainSample') do
    Type('AWS::Elasticsearch::Domain')

    Property('AccessPolicies', elastic_search_policy)
    Property('ElasticsearchClusterConfig',
             'InstanceType' => 't2.medium.elasticsearch',
             'InstanceCount' => 1)
    Property('EBSOptions',
             'EBSEnabled' => true,
             'Iops' => 0,
             'VolumeSize' => 20,
             'VolumeType' => 'gp2')
    Property('ElasticsearchVersion', elastic_search_version)
    Property('AdvancedOptions', elastic_search_options)

    Property('Tags', tags_common)
  end

  Output('ElasticSearchDomainEndpointSample') do
    Value(FnGetAtt('elasticSearchDomainSample', 'DomainEndpoint'))
  end

  Output('ElasticSearchDomainArnSample') do
    Value(FnGetAtt('elasticSearchDomainSample', 'DomainArn'))
  end

  Output('ElasticSearchDomainNameSample') do
    Value(Ref('elasticSearchDomainSample'))
  end
end
