module AuthenticatedUser
  include Devise::TestHelpers

  def before_setup
    super

    user = FactoryGirl.create :user
    sign_in user
  end
end