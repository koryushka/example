require 'helpers/configuration'

module ApiHelper
  extend Configuration

  define_setting :aws_app_arn

  # Send push notification
  def self.send(user_id , payload)
    notification_object = { object: payload }

    message = {
        default: 'Platform was not found',
        APNS: {
                aps: {
                    alert: '',
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
          platform_application_arn: :aws_app_arn,
          token: device_token,
      )
    rescue
      raise InternalServerErrorException, status: :bad_request
    end
  end

  # Remove end_point from SNS
  def delete_endpoint(end_point)
    begin
      @sns.delete_endpoint(endpoint_arn: end_point)
    rescue
      raise InternalServerErrorException, status: :bad_request
    end
  end
end