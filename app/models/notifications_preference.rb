class NotificationsPreference < ActiveRecord::Base
  belongs_to :event

  validates :email, allow_blank: true, inclusion: {in: [true, false]}
  validates :sms, allow_blank: true, inclusion: {in: [true, false]}
  validates :push, allow_blank: true, inclusion: {in: [true, false]}
end
