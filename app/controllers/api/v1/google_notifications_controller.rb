class Api::V1::GoogleNotificationsController < ApiController
  before_filter :authorize_user_from_query_params, except: [:notifications]

  def notifications
    p params.inspect
    render nothing: true
  end

  def notification_subscription

    # data = {
    #   id:  "channel_id" ,
    #   type: "web_hook",
    #   address: Rails.application.secrets.google_notification_url
    # }
    # if calendar_id = params[:calendar_id]
    #   uri = "https://www.googleapis.com/calendar/v3/calendars/#{calendar_id}/events/watch"
    # else
    #   uri = 'https://www.googleapis.com/calendar/v3/users/me/calendarList/watch'
    # end
    # uri = 'https://www.googleapis.com/calendar/v3/users/me/calendarList/watch'
    # response = Net::HTTP.post_form(URI.parse(uri), data)
    # render json: {response: response.body}
  end

  private

  def channel_id(calendar_id)
    Channel.find_or_create_by(user_id: current_user.id, resource_id: ca )
  end

  def unauth_actions
    [:notifications, :notification_subscription]
  end

  def authorize_user_from_query_params
    return unless token_present?
    render nothing: true, status: 401 and return unless current_user_id(params[:token])
  end

  def current_user_id(token)
    doorkeeper_token = Doorkeeper::AccessToken.find_by(token: token, revoked_at: nil)
    @current_user_id = doorkeeper_token.try(:resource_owner_id)
  end

  def token_present?
    if params[:token].blank?
      render json: {error: 'Token required'}, status: 401
      false
    else
      true
    end
  end

end
