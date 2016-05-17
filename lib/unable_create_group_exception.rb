class UnableCreateGroupException < AppException
  def initialize
    super(7, 'You cannot create new group being other group member or owner', nil, :conflict)
  end
end