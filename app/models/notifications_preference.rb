class NotificationsPreference < ActiveRecord::Base
  include Swagger::Blocks

  belongs_to :event

  validates :email, allow_blank: true, inclusion: {in: [true, false]}
  validates :sms, allow_blank: true, inclusion: {in: [true, false]}
  validates :push, allow_blank: true, inclusion: {in: [true, false]}

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER SCHEMA: Model Notification Preference
  # ================================================================================

  # swagger_schema :NotificationPreference
  swagger_schema :NotificationPreference do
    key :type, :object
    property :email do
      key :type, :boolean
      key :description, 'Preference for getting email notification'
      key :default, false
    end
    property :push do
      key :type, :boolean
      key :description, 'Preference for getting push notification'
      key :default, false
    end
    property :sms do
      key :type, :boolean
      key :description, 'Preference for getting sms notification'
      key :default, false
    end
  end # end swagger_schema :NotificationPreference
end
