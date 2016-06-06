require 'helpers/configuration'

module PubnubHelpers
  extend Configuration

  class Publisher
    include Singleton
    attr_reader :pubnub

    def initialize
      logger = Logger.new(STDOUT)
      logger = Logger.new('/dev/null') if Rails.env.test?
      @pubnub = Pubnub.new(
          subscribe_key: 'sub-c-b30e1dac-d56c-11e5-b684-02ee2ddab7fe',
          publish_key: 'pub-c-dc0c88cf-f1dd-468d-88a4-160c26eb981d',
          logger: logger
      )
    end

    def self.publish(message, user_id)
      if Rails.env.test?
        Rails.logger.info "[PubNub] Publishing following message for user #{user_id}:\n#{message}"
        return
      end
      instance.pubnub.publish(
          channel: "curago_dev_#{user_id}",
          message: message
      ) do |envelope|
        #puts envelope.parsed_response
      end
    end

  end
end