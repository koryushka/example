class GoogleAccessToken < ActiveRecord::Base
  include Swagger::Blocks
  belongs_to :user
  has_many :calendars, dependent: :destroy

  def expired?
    Time.now.utc >= self.expires_at# - 3600
  end

  def unsync!
    self.update_column(:synchronizable, false)
    remove_calendars
  end

  def sync!
    self.update_column(:synchronizable, true)
  end

  def revoke!
    self.update_columns(revoked: true)
  end

  def remove_calendars
    self.calendars.destroy_all
  end

  def revoked?
    self.revoked
  end

  swagger_schema :ArrayOfAccounts do
    key :type, :array
    items do
      key :'$ref', :Account
    end
  end

  swagger_schema :AccountInput do
    key :type, :object
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

    property :account do
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
