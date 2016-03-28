require File.expand_path('../../../test_helper', __FILE__)

class DeviseOverrides::RegistrationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  setup do
    @request.env['devise.mapping'] = Devise.mappings[:api_v1_user]
  end

  test 'should successfuly register' do
    password = Faker::Internet.password
    post :create, email: Faker::Internet.email, password: password
    assert_response :success
  end

  test 'should raise validation error' do
    post :create, email: Faker::Internet.email
    assert_response :bad_request
  end

  test 'should raise existing email error' do
    email = Faker::Internet.email
    FactoryGirl.create(:user, email: email)
    post :create, email: email, password: Faker::Internet.password
    assert_response :bad_request
    assert @response.body.include? 'has already been taken'
  end

  # test 'should successfuly update user' do
  #   user = FactoryGirl.create(:user)
  #   auth_headers = user.create_new_auth_token
  #   sign_in user
  #   @request.headers.merge!(auth_headers)
  #
  #   new_user_name = Faker::Lorem.characters(10)
  #   put :update, user_name: new_user_name
  #   assert_response :success
  # end
end
