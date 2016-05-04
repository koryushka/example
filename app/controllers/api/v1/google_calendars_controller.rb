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
      calendar = Calendar.find_or_initialize_by(title: item.id, user_id: current_user.id)
      if calendar.new_record? && calendar.save
        calendars << calendar
      end
      parse_events(calendar)
    end
    render json: {events: @items}
    # render json: {imported: calendars}
  end

  private

  def parse_events(calendar)
    @i ||= 0
    @items ||= []
    @service.list_events(calendar.title).items.each do |item|
      @i += 1
      puts "#{@i} - EVENT #{item.summary} - ID #{item.id}"

        @event = Event.find_or_initialize_by(
          starts_at: start_date(item),
          title: title(item),
          frequency: get_frequency(item),
          user_id: current_user.id,
          google_event_id: item.id
        )

      if @event.new_record? && @event.save
        # puts "#{@i} FREQUENCE = #{@frequence}"

      end
      if @frequence && @event
        calculate_event_recurrence
      end
      # create_event_cancellation
      @frequence = nil if @frequence
      @items << item
    end
  end

  def calculate_event_recurrence
    case @frequence[:FREQ]
      when 'DAILY'  then puts 'DAILY'
      when 'WEEKLY' then create_weekly_event_recurrence
      when 'MONTHLY'then create_monthly_event_recurrence
      when 'YEARLY' then create_yearly_event_recurrence
    end
  end

  def create_weekly_event_recurrence
    days = @frequence[:BYDAY].split(',')
    days.map do |day|
      EventRecurrence.find_or_create_by(
        event_id: @event.id,
        month: nil,
        week: nil,
        day: get_day(day)
      )
    end
  end

  def create_monthly_event_recurrence
    @frequence[:BYDAY].split(',').map do |day|
      day.squish!
      EventRecurrence.find_or_create_by(
      event_id: @event.id,
      week: day.slice!(0).to_i,
      day: get_day(day)
      )
    end
  end

  def create_yearly_event_recurrence
    date = @event.starts_at.to_date
    EventRecurrence.find_or_create_by(
      event_id: @event.id,
      month: date.month,
      week: nil,
      day: date.day
    )
  end

  def get_day(day)
   week = {
      'SU' => 0,'MO' => 1,'TU' => 2,'WE' => 3,'TH' => 4,'FR' => 5,'SA' => 6
    }
    week[day]
  end

  def get_frequency(item)
    if item.recurrence
      @frequence = count_frequency(item.recurrence[0])
      @frequence[:FREQ].downcase
    else
      'once'
    end
  end

  def count_frequency(recurrence)
    rules = recurrence.gsub('RRULE:','').split(';')
    hash = {}
    rules.map do |r|
      pair = r.split('=')
      hash[pair[0].to_sym] = pair[1]
    end
    hash
  end

  def google_token_uri
    google_oauth2_path + '/token'
  end

  def google_oauth_uri
    google_oauth2_path + '/auth'
  end

  def google_oauth2_path
    'https://accounts.google.com/o/oauth2'
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
    if item.status == 'cancelled'
      item.original_start_time.date_time
    else
      item.start.date || item.start.date_time
    end
  end

  def title(item)
    if item.status == 'cancelled'
      Event.find_by_google_event_id(item.recurring_event_id).title || 'No title'
    else
      item.summary
    end
  end

end
