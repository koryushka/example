require File.expand_path('../../../../test_helper', __FILE__)


class Api::V1::DevicesControllerTest < ActionController::TestCase
  include AuthenticatedUser

  test 'should create new device' do
    post :create, {
        device_token: Faker::Number.hexadecimal(64),
    }
    assert_response :success
  end

  test 'should fail invalid device creation' do
    post :create
    assert_response :bad_request
  end

  test 'should destroy existing device' do
    device = FactoryGirl.create(:device, user: @user)
    delete :destroy, id: device.id
    assert_response :no_content
    assert_raises ActiveRecord::RecordNotFound do
      Device.find(device.id)
    end
  end
end