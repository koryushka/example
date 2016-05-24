require File.expand_path('../../../../test_helper', __FILE__)


class Api::V1::DevicesControllerTest < ActionController::TestCase
  include AuthenticatedUser

  test 'should create new device' do
    post :create, {
        device_token: Faker::Number.hexadecimal(64),
        # aws_endpoint_arn: ENV['AWS_APP_ARN']
    }
    assert_response :success
  end

  test 'should fail invalid device creation' do
    post :create
    assert_response :bad_request
  end

  test 'should destroy existing device' do
    device = FactoryGirl.create(:device)
    delete :destroy, device_token: device.device_token
    assert_response :no_content
    # assert_raises ActiveRecord::RecordNotFound do
    #   device.find(device.id)
    # end
  end
end