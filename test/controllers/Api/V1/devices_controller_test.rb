require File.expand_path('../../../../test_helper', __FILE__)


class DeviceControllerTest < ActionController::TestCase
  include AuthenticatedUser

  #### Devices creation
  test 'should create new device' do
    existing_user = FactoryGirl.create(:user)
    user_id << existing_user.id
    post :create, {
        user_id: user_id,
        device_token: Hash[*Faker::Lorem.words(4)],
        aws_endpoint_arn: 'aws:sns:us-west-2:123456789012:MyTopic:2bcfbf39-05c3-41de-beaa-fcfcc21c8f55',
    }
    assert_response :success
  end

  test 'should fail invalid device creation' do
    post :create
    assert_response :bad_request
  end

  #### device update
  test 'should update existing device' do
    existing_user = FactoryGirl.create(:user)
    device = FactoryGirl.create(:device, user: existing_user)
    new_aws_endpoint_arn = 'aws:sns:us-west-2:123456789012:MyTopic:2bcfbf39-05c3-41de-xxxx-xxxxxxxxxxxx'
    put :update, id: device.id, device_token: device.device_token, aws_endpoint_arn: new_aws_endpoint_arn
    assert_response :success
    assert_equal json_response['aws_endpoint_arn'], new_aws_endpoint_arn
    assert_not_equal json_response['aws_endpoint_arn'], device.aws_endpoint_arn
  end

  test 'should fail device update with invalid data' do
    existing_user = FactoryGirl.create(:user)
    device = FactoryGirl.create(:device, user: existing_user)
    put :update, id: device.id, device_token: device.device_token, aws_endpoint_arn: nil
    assert_response :bad_request
  end
end