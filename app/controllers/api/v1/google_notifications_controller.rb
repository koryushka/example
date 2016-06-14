class Api::V1::GoogleNotificationsController < ApiController

  def notifications
    google_resource_id = request.headers['HTTP_X_GOOG_RESOURCE_ID']
    uuid = request.headers['HTTP_X_GOOG_CHANNEL_ID']
    # logger.debug "Google params #{params.inspect}"
    # logger.debug "Google params #{request.headers.inspect}"
    google_channel = GoogleChannel.find_by(uuid: uuid, google_resource_id: google_resource_id)
    if google_channel
      changed_object = google_channel.channelable
      update_changed_object changed_object
    end
    render nothing: true
  end

  private

  def update_changed_object(changed_object)
    user_id = changed_object.user_id
    if changed_object.class == GoogleAccessToken
      google_access_token = changed_object
      calendar_id = nil
    elsif changed_object.class == Calendar
      google_access_token = changed_object.google_access_token
      calendar_id = changed_object.google_calendar_id
    end
    GoogleSyncService.new.sync(user_id, google_access_token, calendar_id, true)
  end

  def unauth_actions
    [:notifications]
  end

end
