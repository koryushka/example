module AuthenticatedUser
  include Devise::TestHelpers

  def before_setup
    super

    @user = FactoryGirl.create :user
    token = Doorkeeper::AccessToken.new(resource_owner_id: @user.id)
    token.save
    @request.headers['Authorization'] = "Bearer #{token.token}"
    #@controller.instance_variable_set('@_doorkeeper_token', token)
    #@controller.instance_variable_set('@doorkeeper_token', token)
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s
  end
end