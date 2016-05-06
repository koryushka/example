class User < ActiveRecord::Base
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
end