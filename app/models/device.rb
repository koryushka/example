class Device < ActiveRecord::Base
  belongs_to :user

  validates :device_token, presence: true
end
