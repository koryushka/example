module ApiHelper
  # Send push notification
  def self.send(device_token, payload)
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