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
  def self.send(devise_token, payload)
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

    # TODO: define devices by devise_token, like this:
    #devices = Device.where(user_id: devise_token) # usage of devise_token
    # devices.each do |device|
    #   next unless device && device.end_point_arn && device.os_type
    #   message = ios_message
    #   next if message.nil?
    #
    #   # send push notification
    #   @sns.publish(
    #       target_arn: device.end_point_arn,
    #       message: message.to_json,
    #       message_structure: 'json'
    #   )
    #
    # end

    # e.g. send push notification
    @sns.publish(
          target_arn: 'arn:aws:sns:us-east-1:XXXXXXXXXXXX:endpoint/APNS_SANDBOX/Neighborly-iOS/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX',
          message: message.to_json,
          message_structure: 'json')
  end
end