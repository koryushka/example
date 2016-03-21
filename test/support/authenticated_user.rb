module AuthenticatedUser
  include Devise::TestHelpers

  def before_setup
    super

    @user = FactoryGirl.create :user
    auth_headers = @user.create_new_auth_token
    sign_in @user
    @request.headers.merge!(auth_headers)
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s
  end
end