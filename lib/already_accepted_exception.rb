class AlreadyAcceptedException < AppException
  def initialize
    super(5, 'This invitation is alredy accepted', nil, :not_acceptable)
  end
end