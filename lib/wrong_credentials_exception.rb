class WrongCredentialsException < AppException

  def initialize
    super(nil, 'Wrong credentials', 'Wrong access and refresh tokens', 403)
  end
end
