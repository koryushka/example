class ApiController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken

  private
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authorize
    render :text => '401. Unauthorized', :status => :unauthorized if current_user.nil?
  end
end
