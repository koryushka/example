class GoogleNotifications

  def subscribe(google_access_token, calendar=nil)
    data = {
      id:  channel_id,
      type: "web_hook",
      address: Rails.application.secrets.google_notification_url,
      params: {
        ttl: '1426325213000'
      }
    }
    url = calendar ? "https://www.googleapis.com/calendar/v3/calendars/#{calendar.google_calendar_id}/events/watch" :
      'https://www.googleapis.com/calendar/v3/users/me/calendarList/watch'

    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    req['Authorization'] = "Bearer #{google_access_token.token}"
    req.body = data.to_json
    response = https.request(req)
    @body = Rails.env.development? ? test_body_for_development : response.body
  end

  def unsubscribe

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

  def test_body_for_development
    {
      "kind": "api#channel",
      "id": "channel_id3sws",
      "resourceId": "RenWL2yx-o6KfYjfp4DwC_2J40Y",
      "resourceUri": "https://www.googleapis.com/calendar/v3/calendars/kkaretnikov@weezlabs.com/events?alt=json",
      "expiration": "1466166074000"
    }
  end

end
