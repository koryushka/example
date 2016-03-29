module AuthenticatedUser
  def before_setup
    super

    @user = FactoryGirl.create :user
    token = Doorkeeper::AccessToken.new(resource_owner_id: @user.id, scopes: 'user')
    token.save
    @request.headers['Authorization'] = "Bearer #{token.token}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s
  end
end