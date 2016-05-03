class Api::V1::GoogleCalendarsController < ApiController
  skip_before_filter :doorkeeper_authorize!, except: [:import_calendars]
  before_action :google_auth, only: [:index, :show, :import_calendars]
  rescue_from Google::Apis::AuthorizationError, with: :show_errors

  def auth
    client = Signet::OAuth2::Client.new({
      authorization_uri: google_oauth_uri,
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY
    }.merge(oauth_params))

    redirect_to client.authorization_uri.to_s
  end

  def oauth2callback
    client = Signet::OAuth2::Client.new({
      token_credential_uri: google_token_uri,
      code: params[:code]
    }.merge(oauth_params))
    response = client.fetch_access_token!
    render json: {access_token: response['access_token']}
  end

  def index
    @calendar_list = @service.list_calendar_lists
  end

  def show
    @calendar_events = @service.list_events(params[:calendar_id])
  end

  def import_calendars
    @calendar_list = @service.list_calendar_lists
    calendars = []
    @calendar_list.items.each do |item|
      calendar = Calendar.find_or_initialize_by(title: item.id, user_id: current_user.id) do |calendar|
        # calendar.kind = item.kind

      end
      if calendar.new_record?
        if calendar.save
          calendars << calendar
        end
      end
      parse_events(calendar)


    end
    render json: {events: @items}
    # render json: {imported: calendars}
  end

  private

  def parse_events(calendar)
    @items ||= []
    @service.list_events(calendar.title).items.each do |item|
      if item.summary.blank?
        puts "EVENT #{item.summary}"
      end
      event = Event.find_or_initialize_by(
        starts_at: start_date(item) || Time.now,
        title: item.summary || "new",
        frequency: 'daily',
        user_id: current_user.id
        ) do |event|
        end
      if event.new_record?
        if event.save
          @items << event
        end
      end


    end

  end

  def google_token_uri
    'https://accounts.google.com/o/oauth2/token'
  end

  def google_oauth_uri
    'https://accounts.google.com/o/oauth2/auth'
  end

  def oauth_params
    {
      expires_in: 604800,
      client_id: Rails.application.secrets.google_client_id,
      client_secret: Rails.application.secrets.google_client_secret,
      redirect_uri: url_for(:action => :oauth2callback)
    }
  end

  def google_auth
    client = Signet::OAuth2::Client.new(access_token: params[:access_token])
    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.authorization = client
    render json: {error: 'Access-token required'}, status: 403 and return unless params[:access_token]
  end

  def show_errors
    render json: {error: 'Invalid access-token. Generate new one.'}, status: 401
  end

  def start_date(item)
    if item.start
      item.start.date || item.start.date_time
    end
  end

end
