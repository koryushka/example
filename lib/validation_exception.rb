class ValidationException < AppException
  attr_accessor :model

  def initialize(model)
    @model = model
    super(1, I18n.t('errors.messages.validation_error'), model.errors.messages, :bad_request)
  end
end