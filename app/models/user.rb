class User < ActiveRecord::Base
  has_many :calendars
  has_many :calendar_items
  has_many :calendars_groups
  has_many :lists
  has_many :documents
  has_many :sharing_permissions

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  validates :user_name, length: {maximum: 32}, presence: true
  validates :email, length: {maximum: 128}, presence: true,
            email_format: {:message => "doesn't look like an email address."},
            uniqueness: true
=begin
  validates :password, length: {maximum: 128}
  validates :password_confirmation, presence: true, :on => :create

  has_secure_password
=end
end