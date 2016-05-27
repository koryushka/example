class InternalServerErrorException < AppException
  def initialize
    super(500, 'Internal error', nil, :internal_server_error)
  end
end