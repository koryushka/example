class PasswordUpdate
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :code, :password
  validates :code, length: {maximum: 5, minimum: 5}, presence: true
  validates :password, length: {maximum: 128}, presence: true, confirmation: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end