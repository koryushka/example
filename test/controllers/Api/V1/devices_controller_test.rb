require File.expand_path('../../../../test_helper', __FILE__)


class Api::V1::DevicesControllerTest < ActionController::TestCase
  include AuthenticatedUser

  test 'should create new device' do
    existing_user = FactoryGirl.create(:user)
    post :create, {
        user_id: existing_user.id,
        device_token: Faker::Lorem.characters(32),
        aws_endpoint_arn: 'arn:aws:sns:us-west-2:319846285652:app/APNS_SANDBOX/cuAPNS',
    }
    assert_response :success
  end

  test 'should fail invalid device creation' do
    post :create
    assert_response :bad_request
  end

  test 'should update existing device' do
    existing_user = FactoryGirl.create(:user)
    device = FactoryGirl.create(:device, user: existing_user)
    appName = 'CuragoTest'
    new_aws_endpoint_arn = 'arn:aws:sns:us-west-2:'+ Faker::Number.number(12) + ':app/APNS_SANDBOX/' + appName
    put :update, id: device.id, device_token: device.device_token, aws_endpoint_arn: new_aws_endpoint_arn
    assert_response :success

  end

  test 'should fail device update with invalid data' do
    existing_user = FactoryGirl.create(:user)
    device = FactoryGirl.create(:device, user: existing_user)
    put :update, id: device.id, device_token: device.device_token, aws_endpoint_arn: nil
    assert_response :bad_request
  end

end