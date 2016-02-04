class NotificationsPreference < ActiveRecord::Base
  has_one :calendar
  has_one :calendar_item

  validates :email, allow_blank: true, inclusion: {in: [true, false]}
  validates :sms, allow_blank: true, inclusion: {in: [true, false]}
  validates :push, allow_blank: true, inclusion: {in: [true, false]}
end
