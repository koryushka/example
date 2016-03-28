class ValidationException < Exception
  attr_accessor :model

  def initialize(model)
    @model = model
    super('')
  end
end