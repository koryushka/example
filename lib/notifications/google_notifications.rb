class GoogleNotifications

  def initialize(google_access_token)
    @google_access_token = google_access_token
  end

  def subscribe(calendar=nil)
    data = {
      id:  channel_id,
      type: "web_hook",
      address: Rails.application.secrets.google_notification_url,
      params: {
        ttl: '1426325213000'
      }
    }
    url = calendar ? "https://www.googleapis.com/calendar/v3/calendars/#{URI.escape(calendar.google_calendar_id)}/events/watch") :
      'https://www.googleapis.com/calendar/v3/users/me/calendarList/watch'

    post_request(url, data)
    @body = Rails.env.development? ? test_body_for_development : @response.body
  end

  def unsubscribe(ch_id, res_id)
    url = 'https://www.googleapis.com/calendar/v3/channels/stop'
    data = {
      id:  ch_id,
      resourceId: res_id
    }
    post_request(url, data)
    puts @response.body
  end

  def channel
    # GoogleChannel.find_or_create by(google_access_token_id: google_access_token.id) do |gc|
    #   uuid: SecureRandom.uuid
    # end
  end

  def channel_id
    uuid = SecureRandom.uuid
    channel_id while GoogleChannel.find_by_uuid(uuid)
    uuid
  end

  def post_request(url, data)
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    req['Authorization'] = "Bearer #{@google_access_token.token}"
    req.body = data.to_json
    Rails.logger.debug "REQUEST URL #{url}"
    Rails.logger.debug "GOOGLE REQUEST #{req.body}"
    @response = https.request(req)
  end

  def test_body_for_development
    {
      "kind": "api#channel",
      "id": "fake_channel_id",
      "resourceId": "RenWL2yx-o6KfYjfp4DwC_2J40Y",
      "resourceUri": "https://www.googleapis.com/calendar/v3/calendars/kkaretnikov@weezlabs.com/events?alt=json",
      "expiration": "1466166074000"
    }
  end

end
