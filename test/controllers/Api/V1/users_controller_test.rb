require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::UsersControllerTest < ActionController::TestCase
  include AuthenticatedUser

  test 'should user object with profile' do
    get :me
    assert_response :success
    assert_not_nil json_response['profile']
  end
end
