class User < ActiveRecord::Base
  has_many :calendars
  has_many :events
  has_many :calendars_groups
  has_many :lists
  has_many :documents
  has_many :sharing_permissions
  has_many :list_items

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  validates :email, length: {maximum: 128}, presence: true,
            email_format: {:message => "doesn't look like an email address."},
            uniqueness: true

  def clean_tokens
    Doorkeeper::AccessToken.where(scopes: 'user', resource_owner_id: id)
        .where(%q[created_at + expires_in * INTERVAL '1 second' < now() OR revoked_at IS NOT NULL AND revoked_at < now()])
        .delete_all
  end
end