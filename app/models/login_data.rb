class LoginData
  include ActiveModel::Model

  attr_accessor :username, :password, :scope, :grant_type, :refresh_token

  validates :username, presence: true, length: {in:2..255}, email_format: {:message => "doesn't look like an email address."}
  validates :password, presence: true
  validates :scope, allow_blank: true, inclusion: {in: %w(user admin)}
  validates :grant_type, presence: true, inclusion: {in: %w(password refresh_token)}
end