class ApiController < ActionController::Base

  #include DeviseTokenAuth::Concerns::SetUserByToken

  def pubnub
    @pubnub ||= Pubnub.new(
        subscribe_key: 'sub-c-b30e1dac-d56c-11e5-b684-02ee2ddab7fe',
        publish_key: 'pub-c-dc0c88cf-f1dd-468d-88a4-160c26eb981d'
    )
  end

  def publish(message)
    pubnub.publish(
        channel: "curago_dev_#{tmp_user.id}",
        message: message
    ) do |envelope|
      puts envelope.parsed_response
    end
  end

  def something_updated
    publish('updated')
  end

private
  def tmp_user
    @tmp_user ||= User.find(5)
  end
end
