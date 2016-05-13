module ApiHelper
  # SNS connection
  def self.sns
    @sns = AWS::SNS::Client.new(
        # TODO: Need to define region, access_key_id, secret_access_key
        region: 'us-east-1',
        access_key_id: 14,
        secret_access_key: 'ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890',
    )
  end

  # Send push notification
  def self.send(device_token, payload)
    ApiHelper::sns
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

    devices = Device.where(user_id: device_token)
    devices.each do |device|
      @sns.publish(
            target_arn: device.aws_endpoint_arn,
            message: message.to_json,
            message_structure: 'json')
    end
  end
end