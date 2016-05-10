class User < ActiveRecord::Base
  include Swagger::Blocks

  has_many :calendars
  has_many :events
  has_many :calendars_groups
  has_many :lists
  has_many :documents
  has_many :sharing_permissions
  has_many :list_items
  has_many :groups
  has_one :profile
  has_many :muted_events

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  after_create do
    Profile.create(user: self)
  end

  validates :email, length: {maximum: 128}, presence: true,
            email_format: {:message => "doesn't look like an email address."},
            uniqueness: true

  def clean_tokens
    Doorkeeper::AccessToken.where(scopes: 'user', resource_owner_id: id)
        .where(%q[created_at + expires_in * INTERVAL '1 second' < now() OR revoked_at IS NOT NULL AND revoked_at < now()])
        .delete_all
  end

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER SCHEMA: Model User
  # ================================================================================

  # swagger_schema :User
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
  end # end swagger_schema :User

  # swagger_schema :RegistrationInput
  swagger_schema :RegistrationInput do
    key :type, :object
    property :email do
      key :type, :string
      key :description, 'Email of registered user'
    end
    property :password do
      key :type, :string
    end
  end # end swagger_schema :RegistrationInput

  # swagger_schema :UserUpdateInput
  swagger_schema :UserUpdateInput do
    key :type, :object
    property :email do
      key :type, :string
      key :description, 'Email of registered user'
    end
    property :password do
      key :type, :string
      key :description, "New user's password"
    end
    property :current_password do
      key :type, :string
      key :description, "Current user's password. Required if password is going to be changed"
    end
  end # end swagger_schema :UserUpdateInput

  swagger_schema :PasswordResetInput do
    key :type, :object
    key :required, %w(email redirect_url)
    property :email do
      key :type, :string
      key :description, 'Email of user who requested password resetting'
      key :format, 'email'
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
    key :required, %w(email redirect_url)
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
