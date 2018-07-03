CloudFormation do
  AWSTemplateFormatVersion('2010-09-09')
  Description "WAF v1"

  Parameter('environmentType') { Type 'String' }

  Mapping('regions',
          'us-east-1' => {
            'metricNamesFormatted' => 'usEast1'
          },
          'ap-southeast-2' => {
            'metricNamesFormatted' => 'apSouthEast2'
          })

  ####################
  # WAF set(s) below
  ####################

  Resource('WAFIPSetWhitelist') do
    Type('AWS::WAF::IPSet')

    Property('Name',
             FnJoin('', [
                      Ref('environmentType'),
                      '-ip-white-list-',
                      Ref('AWS::Region')
                    ]))
  end

  Resource('WAFIPSetBlacklist') do
    Type('AWS::WAF::IPSet')

    Property('Name',
             FnJoin('', [
                      Ref('environmentType'),
                      '-ip-black-list-',
                      Ref('AWS::Region')
                    ]))
  end

  Resource('WAFSqlInjectionMatchSet') do
    Type('AWS::WAF::SqlInjectionMatchSet')

    Property('Name',
             FnJoin('', [
                      Ref('environmentType'),
                      '-sql-injection-match-set-',
                      Ref('AWS::Region')
                    ]))

    Property('SqlInjectionMatchTuples', [
               {
                 'FieldToMatch' => {
                   'Type' => 'QUERY_STRING'
                 },
                 'TextTransformation' => 'URL_DECODE'
               }, {
                 'FieldToMatch' => {
                   'Type' => 'QUERY_STRING'
                 },
                 'TextTransformation' => 'HTML_ENTITY_DECODE'
               }, {
                 'FieldToMatch' => {
                   'Type' => 'BODY'
                 },
                 'TextTransformation' => 'URL_DECODE'
               }, {
                 'FieldToMatch' => {
                   'Type' => 'BODY'
                 },
                 'TextTransformation' => 'HTML_ENTITY_DECODE'
               }, {
                 'FieldToMatch' => {
                   'Type' => 'URI'
                 },
                 'TextTransformation' => 'URL_DECODE'
               }, {
                 'FieldToMatch' => {
                   'Type' => 'URI'
                 },
                 'TextTransformation' => 'HTML_ENTITY_DECODE'
               }, {
                 'FieldToMatch' => {
                   'Type' => 'HEADER',
                   'Data' => 'Cookie'
                 },
                 'TextTransformation' => 'URL_DECODE'
               }, {
                 'FieldToMatch' => {
                   'Type' => 'HEADER',
                   'Data' => 'Cookie'
                 },
                 'TextTransformation' => 'HTML_ENTITY_DECODE'
               }, {
                 'FieldToMatch' => {
                   'Type' => 'HEADER',
                   'Data' => 'Authorization'
                 },
                 'TextTransformation' => 'URL_DECODE'
               }, {
                 'FieldToMatch' => {
                   'Type' => 'HEADER',
                   'Data' => 'Authorization'
                 },
                 'TextTransformation' => 'HTML_ENTITY_DECODE'
               }
             ])
  end

  Resource('WAFXssMatchSet') do
    Type('AWS::WAF::XssMatchSet')

    Property('Name',
             FnJoin('', [
                      Ref('environmentType'),
                      '-xss-match-set-',
                      Ref('AWS::Region')
                    ]))

    Property('XssMatchTuples',
             [{
               'FieldToMatch' => {
                 'Type' => 'QUERY_STRING'
               },
               'TextTransformation' => 'URL_DECODE'
             }, {
               'FieldToMatch' => {
                 'Type' => 'QUERY_STRING'
               },
               'TextTransformation' => 'HTML_ENTITY_DECODE'
             }, {
               'FieldToMatch' => {
                 'Type' => 'BODY'
               },
               'TextTransformation' => 'URL_DECODE'
             }, {
               'FieldToMatch' => {
                 'Type' => 'BODY'
               },
               'TextTransformation' => 'HTML_ENTITY_DECODE'
             }, {
               'FieldToMatch' => {
                 'Type' => 'URI'
               },
               'TextTransformation' => 'URL_DECODE'
             }, {
               'FieldToMatch' => {
                 'Type' => 'URI'
               },
               'TextTransformation' => 'HTML_ENTITY_DECODE'
             }, {
               'FieldToMatch' => {
                 'Type' => 'HEADER',
                 'Data' => 'Cookie'
               },
               'TextTransformation' => 'URL_DECODE'
             }, {
               'FieldToMatch' => {
                 'Type' => 'HEADER',
                 'Data' => 'Cookie'
               },
               'TextTransformation' => 'HTML_ENTITY_DECODE'
             }])
  end

  ####################
  # Rule(s) below
  ####################

  Resource('WAFRuleIPWhiteList') do
    Type('AWS::WAF::Rule')

    Property('Name',
             FnJoin('', [
                      Ref('environmentType'),
                      '-ip-white-list-',
                      Ref('AWS::Region')
                    ]))

    Property('MetricName',
             FnJoin('', [
                      Ref('environmentType'),
                      'ipwhitelist',
                      FnFindInMap('regions', Ref('AWS::Region'), 'metricNamesFormatted')
                    ]))

    Property('Predicates', [{
               'DataId' => Ref('WAFIPSetWhitelist'),
               'Negated' => false,
               'Type' => 'IPMatch'
             }])

    DependsOn([
                'WAFIPSetWhitelist'
              ])
  end

  Resource('WAFRuleIPBlackList') do
    Type('AWS::WAF::Rule')

    Property('Name',
             FnJoin('', [
                      Ref('environmentType'),
                      '-ip-black-list-',
                      Ref('AWS::Region')
                    ]))

    Property('MetricName',
             FnJoin('', [
                      Ref('environmentType'),
                      'ipblacklist',
                      FnFindInMap('regions', Ref('AWS::Region'), 'metricNamesFormatted')
                    ]))

    Property('Predicates', [{
               'DataId' => Ref('WAFIPSetBlacklist'),
               'Negated' => false,
               'Type' => 'IPMatch'
             }])

    DependsOn([
                'WAFIPSetBlacklist'
              ])
  end

  Resource('WAFRuleSQLInjection') do
    Type('AWS::WAF::Rule')

    Property('Name',
             FnJoin('', [
                      Ref('environmentType'),
                      '-sql-injection-',
                      Ref('AWS::Region')
                    ]))

    Property('MetricName',
             FnJoin('', [
                      Ref('environmentType'),
                      'sqlinjection',
                      FnFindInMap('regions', Ref('AWS::Region'), 'metricNamesFormatted')
                    ]))

    Property('Predicates', [{
               'DataId' => Ref('WAFSqlInjectionMatchSet'),
               'Negated' => false,
               'Type' => 'SqlInjectionMatch'
             }])

    DependsOn([
                'WAFSqlInjectionMatchSet'
              ])
  end

  Resource('WAFRuleXssDetection') do
    Type('AWS::WAF::Rule')

    Property('Name',
             FnJoin('', [
                      Ref('environmentType'),
                      '-xss-detection-',
                      Ref('AWS::Region')
                    ]))

    Property('MetricName',
             FnJoin('', [
                      Ref('environmentType'),
                      'xssdetection',
                      FnFindInMap('regions', Ref('AWS::Region'), 'metricNamesFormatted')
                    ]))

    Property('Predicates', [{
               'DataId' => Ref('WAFXssMatchSet'),
               'Negated' => false,
               'Type' => 'XssMatch'
             }])

    DependsOn([
                'WAFXssMatchSet'
              ])
  end

  Resource('WAFWebACLApis') do
    Type('AWS::WAF::WebACL')

    Property('DefaultAction',
             'Type' => 'ALLOW')

    Property('MetricName',
             FnJoin('', [
                      Ref('environmentType'),
                      'wafruleapi',
                      FnFindInMap('regions', Ref('AWS::Region'), 'metricNamesFormatted')
                    ]))

    Property('Name',
             FnJoin('', [
                      Ref('environmentType'),
                      '-apis-',
                      Ref('AWS::Region')
                    ]))

    Property('Rules', [
               {
                 'Action' => {
                   'Type' => 'ALLOW'
                 },
                 'Priority' => 1,
                 'RuleId' => Ref('WAFRuleIPWhiteList')
               },
               {
                 'Action' => {
                   'Type' => 'BLOCK'
                 },
                 'Priority' => 2,
                 'RuleId' => Ref('WAFRuleIPBlackList')
               },
               {
                 'Action' => {
                   'Type' => 'BLOCK'
                 },
                 'Priority' => 3,
                 'RuleId' => Ref('WAFRuleSQLInjection')
               },
               {
                 'Action' => {
                   'Type' => 'BLOCK'
                 },
                 'Priority' => 4,
                 'RuleId' => Ref('WAFRuleXssDetection')
               }
             ])

    DependsOn([
                'WAFRuleIPWhiteList',
                'WAFRuleIPBlackList',
                'WAFRuleSQLInjection',
                'WAFRuleXssDetection'
              ])
  end

  Resource('WAFWebACLWeb') do
    Type('AWS::WAF::WebACL')

    Property('DefaultAction',
             'Type' => 'ALLOW')

    Property('MetricName',
             FnJoin('', [
                      Ref('environmentType'),
                      'wafruleweb',
                      FnFindInMap('regions', Ref('AWS::Region'), 'metricNamesFormatted')
                    ]))

    Property('Name',
             FnJoin('', [
                      Ref('environmentType'),
                      '-web-',
                      Ref('AWS::Region')
                    ]))

    Property('Rules', [
               {
                 'Action' => {
                   'Type' => 'ALLOW'
                 },
                 'Priority' => 1,
                 'RuleId' => Ref('WAFRuleIPWhiteList')
               },
               {
                 'Action' => {
                   'Type' => 'BLOCK'
                 },
                 'Priority' => 2,
                 'RuleId' => Ref('WAFRuleIPBlackList')
               },
               {
                 'Action' => {
                   'Type' => 'BLOCK'
                 },
                 'Priority' => 3,
                 'RuleId' => Ref('WAFRuleSQLInjection')
               }
             ])

    DependsOn([
                'WAFRuleIPWhiteList',
                'WAFRuleIPBlackList',
                'WAFRuleSQLInjection'
              ])
  end

  Output('WAFWebACLIdWeb') do
    Value(Ref('WAFWebACLWeb'))
  end

  Output('WAFWebACLIdAPI') do
    Value(Ref('WAFWebACLWeb'))
  end
end
