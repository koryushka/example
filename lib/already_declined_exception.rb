class AlreadyDeclinedException < AppException
  def initialize
    super(6, 'This invitation is alredy declined', nil, :not_acceptable)
  end
end