class GoogleAccessToken < ActiveRecord::Base
  include Swagger::Blocks
  include GoogleAuth
  belongs_to :user
  has_many :calendars, dependent: :destroy

  validates :token, presence: true
  validates :refresh_token, presence: true

  has_one :google_channel, as: :channelable, dependent: :destroy

  def expired?
    Time.now.utc >= self.expires_at
  end

  # def unsync!
  #   self.update_column(:synchronizable, false)
  #   remove_calendars
  # end
  #
  # def sync!
  #   self.update_column(:synchronizable, true)
  # end

  def revoke!
    self.update_columns(revoked: true)
  end

  def remove_calendars
    self.calendars.includes(:events).destroy_all
  end

  def revoked?
    self.revoked
  end

  #TODO dry
  def unsubscribe!
    authorize self
    subscription_service = GoogleNotifications.new(self)
    remove_channel(self, subscription_service)
    self.calendars.each { |calendar| remove_channel(calendar, subscription_service) } unless self.calendars.empty?
  end

  def remove_channel(resource, service)
    google_channel = resource.google_channel
    channel_id, resource_id = google_channel.uuid, google_channel.google_resource_id
    service.unsubscribe(channel_id, resource_id)
    google_channel.destroy
  end

  swagger_schema :ArrayOfAccounts do
    key :type, :array
    items do
      key :'$ref', :Account
    end
  end

  swagger_schema :AccountInput do
    key :type, :object
    key :required, %w(synchronizable)
    property :synchronizable do
      key :type, :boolean
    end
  end

  swagger_schema :AccessToken do
    key :type, :object
    property :info do
      key :type, :string
      key :description, 'Returns google account which was connected to current_user'
    end
    property :access_token do
      key :type, :string
      key :description, 'Google access_token after refresh. This field appears if access_token in params is expired or invalid'
    end
  end

  swagger_schema :Account do
    key :type, :object
    property :id do
      key :type, :integer
      key :description, 'Account ID'
    end

    property :account_name do
      key :type, :string
      key :description, 'Account name'
    end

    property :revoked do
      key :type, :boolean
      key :description, 'Specifies if access to Google account has been revoked by user'
      key :default, false
    end

    property :synchronizable do
      key :type, :boolean
      key :description, 'Specifies if account is synchronizable with external service'
      key :default, true
    end

    property :calendars do
      key :type, :array
      items do
        key :'$ref', :CalendarList
      end
    end
  end

end
