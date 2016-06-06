require File.expand_path('../../../../test_helper', __FILE__)


class Api::V1::DevicesControllerTest < ActionController::TestCase
  include AuthenticatedUser

  test 'should create new device' do
    device_token = Faker::Number.hexadecimal(64)
    post :create, {
        device_token: device_token,
    }
    assert_response :success
    device = Device.find_by_device_token(device_token)
    assert_not_nil Device.find_by_user_id(device.user_id)
    assert_not_nil Device.find_by_aws_endpoint_arn(device.aws_endpoint_arn)

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

  test 'should raise sns unsuccessful exception' do
    post :create, {
        device_token: Faker::Number.hexadecimal(32), # real device_token must be hexadecimal(64)
    }
    assert_response :not_acceptable

  end

end