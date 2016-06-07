require 'helpers/configuration'

module PubnubHelper
  extend Configuration
  define_setting :subscribe_key
  define_setting :publish_key

  class Publisher
    include Singleton
    attr_reader :pubnub

    def initialize

      @pubnub = Pubnub.new(
          subscribe_key: PubnubHelper.subscribe_key,
          publish_key: PubnubHelper.publish_key
      ) unless Rails.env.test?
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