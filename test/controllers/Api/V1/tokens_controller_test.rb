require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::TokensControllerTest < ActionController::TestCase
  #### Tokens creation group
  test 'should create new token' do
    password = Faker::Internet.password
    user = FactoryGirl.create(:user, password: password)
    post :create, {
        username: user.email,
        password: password,
        grant_type: 'password'
    }
    assert_response :success
  end

  test 'should fail with invalid token creation' do
    password = Faker::Internet.password
    user = FactoryGirl.create(:user, password: password)
    post :create, {
        username: user.email,
        password: password,
        grant_type: nil
    }
    assert_response :bad_request
  end
end
