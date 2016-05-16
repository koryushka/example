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

end