class InternalServerErrorException < AppException
  def initialize
    super(500, 'Internale error', nil, :internal_server_error)
  end
end