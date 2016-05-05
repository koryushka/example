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
    new_first_name = Faker::Name.first_name
    put :update, first_name: new_first_name
    assert_response :success
    assert_equal json_response['first_name'], new_first_name
  end
end
