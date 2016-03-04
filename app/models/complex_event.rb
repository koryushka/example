class ComplexEvent < ActiveRecord::Base
  self.primary_key = 'id'
  has_one :event, foreign_key: 'id'

  def readonly?
    true
  end
end
