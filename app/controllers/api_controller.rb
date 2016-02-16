class ApiController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_filter :authenticate_api_user!

  rescue_from CanCan::AccessDenied do
    render :text => '401. Unauthorized. You are not permited for this resourse.', :status => :unauthorized
  end

  def current_user
    send "current_#{controller_scope}_user"
  end

private
  def tmp_user
    @tmp_user ||= User.find(5)
  end

  def controller_scope
    self.class.name.deconstantize.split('::').join('_').downcase
  end

  def authenticate_api_user!
    send "authenticate_#{controller_scope}_user!"
  end
end
