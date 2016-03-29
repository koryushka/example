require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'should cleant tokens' do
    user = FactoryGirl.create(:user)
    expired_token = Doorkeeper::AccessToken.create(
        resource_owner_id: user.id, scopes: 'user', expires_in: 0)
    revoked_token = Doorkeeper::AccessToken.create(
        resource_owner_id: user.id, scopes: 'user', revoked_at: Date.today - 1.minute, expires_in: 1.week)

    #sleep(10)
    user.clean_tokens

    assert_not Doorkeeper::AccessToken.exists?(expired_token.id), %q[Expired token wasn't removed]
    assert_not Doorkeeper::AccessToken.exists?(revoked_token.id), %q[Revoked token wasn't removed]
  end
end
