class SnsUnsuccessfulException < AppException
  def initialize(error)
    super(8, 'Response from AWS::SNS have unsuccessful status', error, :not_acceptable)
  end
end