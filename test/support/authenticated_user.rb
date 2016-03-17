module AuthenticatedUser
  include Devise::TestHelpers

  def before_setup
    super

    @user = FactoryGirl.create :user
    sign_in @user

    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s
  end
end