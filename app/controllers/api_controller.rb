class ApiController < ActionController::Base

  #include DeviseTokenAuth::Concerns::SetUserByToken
private
  def tmp_user
    @tmp_user ||= User.find(5)
  end
end
