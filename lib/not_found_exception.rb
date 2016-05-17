class NotFoundException < AppException
  def initialize
    super(4, I18n.t('errors.messages.not_found'), nil, :not_found)
  end
end