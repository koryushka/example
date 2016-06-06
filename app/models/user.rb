class User < ActiveRecord::Base
  include Swagger::Blocks

  has_many :calendars, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :lists, dependent: :destroy
  has_many :list_items, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_one :profile, dependent: :destroy
  has_many :muted_events, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :sent_paticipations, class_name: 'Participation', foreign_key: 'sender_id'
  has_many :participations
  has_many :devices, dependent: :destroy
  has_many :google_access_tokens, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  after_create do
    Profile.create(user: self)
  end

  validates :email, length: {maximum: 128}, presence: true,
            email_format: {message: "doesn't look like an email address."},
            uniqueness: true

  def clean_tokens
    Doorkeeper::AccessToken.where(scopes: 'user', resource_owner_id: id)
        .where(%q[created_at + expires_in * INTERVAL '1 second' < now() OR revoked_at IS NOT NULL AND revoked_at < now()])
        .delete_all
  end

  # TODO: make it simpler without additional N+1 queries
  def family
    participation = participations.where(participationable_type: Group.name,
                                         status: Participation::ACCEPTED).first
    return participation.participationable if participation.present?
    groups.includes(participations: [:user, :sender]).first
  end

  def all_events(range_start, range_end, time_zone, filter)
    Event.all_of_user(id, range_start, range_end, time_zone, filter)
        .with_muted(id)
        .includes(:list, user: :profile,
                  participations: [
                    {user: :profile},
                    {sender: :profile}
                ])
  end

  swagger_schema :User do
    key :type, :object
    property :id do
      key :type, :integer
    end
    property :email do
      key :type, :string
    end
    property :profile do
      key :'$ref', :Profile
    end
    property :group do
      key :'$ref', :Group
    end
  end

  swagger_schema :UserWithProfileOnly do
    key :type, :object
    property :id do
      key :type, :integer
    end
    property :email do
      key :type, :string
    end
    property :profile do
      key :'$ref', :Profile
    end
  end

  swagger_schema :RegistrationInput do
    key :type, :object
    key :required, %w(email password)
    property :email do
      key :type, :string
      key :description, 'Email of registered user'
      key :maxLength, 128
    end
    property :password do
      key :type, :string
    end
  end

  swagger_schema :UserUpdateInput do
    key :type, :object
    key :required, %w(email password current_password)
    property :email do
      key :type, :string
      key :description, 'Email of registered user'
      key :maxLength, 128
    end
    property :password do
      key :type, :string
      key :description, "New user's password"
    end
    property :current_password do
      key :type, :string
      key :description, "Current user's password. Required if password is going to be changed"
    end
  end

  swagger_schema :PasswordResetInput do
    key :type, :object
    key :required, %w(email redirect_url)
    property :email do
      key :type, :string
      key :description, 'Email of user who requested password resetting'
      key :format, 'email'
      key :maxLength, 128
    end
    property :redirect_url do
      key :description, 'The url to which the user will be redirected after
visiting the link contained in the received email'
      key :type, :string
      key :format, :url
    end
  end

  swagger_schema :PasswordChangeInput do
    key :type, :object
    key :required, %w(password password_confirmation)
    property :password do
      key :type, :string
      key :description, 'New password'
    end
    property :password_confirmation do
      key :description, 'New password confirmation'
      key :type, :string
    end
  end

end
