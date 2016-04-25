require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::ProfilesControllerTest < ActionController::TestCase
  include AuthenticatedUser

  test 'should get show' do
    user = FactoryGirl.create(:user)
    get :show, user_id: user.id
    assert_response :success
    assert_not_nil json_response
    assert_equal json_response['id'], user.profile.id
  end

  test 'should get my profile' do
    get :my_profile
    assert_response :success
    assert_not_nil json_response
    assert_equal json_response['id'], @user.profile.id
  end

  #### Profile update group
  test 'should update profile of current user' do
    new_full_name = Faker::Name.name
    put :update, full_name: new_full_name
    assert_response :success
    assert_equal json_response['full_name'], new_full_name
  end
end
