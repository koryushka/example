class AbstractModel < ActiveRecord::Base
  self.abstract_class = true
  def save
    raise ValidationException.new(self) if invalid?
    super
  end
end