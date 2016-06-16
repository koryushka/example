require 'helpers/configuration'

module ApiHelper
  extend Configuration


  define_setting :aws_access_key_id
  define_setting :aws_secret_access_key
  define_setting :region
  define_setting :aws_app_arn

  class Sns
    def initialize
      @sns = Aws::SNS::Client.new(
          region: ApiHelper.region,
          credentials: Aws::Credentials.new(ApiHelper.aws_access_key_id, ApiHelper.aws_secret_access_key)
      )
    end

    # Send push notification
    def send(user_id , payload)
      notification_object = { object: payload }

      message = {
          default: 'Platform was not found',
          APNS: {
                  aps: {
                      alert: payload[:alert],
                      sound: 'default',
                      badge: 1
                  },
                  notification: notification_object
          }.to_json
      }

      devices = Device.where(user_id: user_id)
      devices.each do |device|
        @sns.publish(
              target_arn: device.aws_endpoint_arn,
              message: message.to_json,
              message_structure: 'json')
      end
    end

    # Insert device token to SNS
    def insert_token(device_token)
      begin
        @sns.create_platform_endpoint(
            platform_application_arn: ApiHelper.aws_app_arn,
            token: device_token,
        )
      rescue => e
        raise SnsUnsuccessfulException.new({code: e.code, message: e.message})
      end
    end

    # Remove end_point from SNS
    def delete_endpoint(end_point)
      begin
        @sns.delete_endpoint(endpoint_arn: end_point)
      rescue => e
        raise SnsUnsuccessfulException.new({code: e.code, message: e.message})
      end
    end
  end
end