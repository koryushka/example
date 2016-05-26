class SnsUnsuccessfulException < AppException
  def initialize
    super(8, 'Response from AWS::SNS have unsuccessful status', nil, :not_acceptable)
  end
end