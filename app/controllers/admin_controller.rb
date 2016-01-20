class AdminController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_filter :authenticate_admin_admin!

end