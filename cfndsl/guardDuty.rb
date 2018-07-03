CloudFormation do
  AWSTemplateFormatVersion('2010-09-09')
  Description "guardDuty v1"

  # The AWS::GuardDuty::Detector resource creates a single Amazon GuardDuty detector.
  # A detector is an object that represents the GuardDuty service.
  # You must create a detector for GuardDuty to become operational.
  # For more information about master / member relationship follow the below
  # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-guardduty-master.html
  # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-guardduty-member.html

  Resource('guardDutyDetector') do
    Type('AWS::GuardDuty::Detector')

    Property('Enable', true)
  end
end
