class AlreadyDeclinedException < AppException
  def initialize
    super(6, 'This invitation is already declined', nil, :not_acceptable)
  end
end