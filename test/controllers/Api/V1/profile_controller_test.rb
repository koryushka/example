require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::ProfilesControllerTest < ActionController::TestCase
  include AuthenticatedUser

  test 'should get show' do
    user = FactoryGirl.create(:user_with_profile)
    get :show, user_id: user.id
    assert_response :success
    assert_not_nil assigns(:profile)
    assert_equal assigns(:profile).id, user.profile.id
  end

  test 'should create new profile for current user' do
    post :create, {
        full_name: Faker::Name.name,
        image_url: Faker::Avatar.image,
        color: Faker::Color.hex_color[-6]
    }
    assert_response :success
    assert_not_nil assigns(:profile)
  end

  test 'should fail invalid profile creation' do
    post :create, {
        full_name: 'x' * 65,
        image_url: 'x' * 2049,
        color: 'x' * 7
    }
    assert_response :bad_request
  end

  test 'should update profile of current user' do
    FactoryGirl.create(:profile, user: @user)
    new_full_name = Faker::Name.name
    put :update, full_name: new_full_name
    assert_response :success
    assert_equal assigns(:profile).full_name, new_full_name
  end
end
