class Api::V1::GoogleCalendarsController < ApiController
  skip_before_filter :doorkeeper_authorize!, except: [:import_calendars]
  before_action :google_auth, only: [:index, :show, :import_calendars]
  before_action :set_client, only: [:auth, :oauth2callback]
  rescue_from Google::Apis::AuthorizationError, with: :show_errors

  def auth
    puts @client.inspect
    redirect_to @client.authorization_uri.to_s
  end

  def oauth2callback
    response = @client.fetch_access_token!
    render json: {data: response}
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
      @calendar = Calendar.find_or_initialize_by(title: item.id, user_id: current_user.id)
      if @calendar.new_record? && @calendar.save
        calendars << @calendar
      end
      parse_events_from_calendar
    end
    render json: {events: @items}
  end

  private

  def parse_events_from_calendar
    @i ||= 0
    @items ||= []
    @service.list_events(@calendar.title).items.each do |item|
      @i += 1
      puts "#{@i} - EVENT #{item.summary} - ID #{item.id}"
      @event = Event.find_or_initialize_by(
        starts_at: start_date(item),
        title: title(item),
        frequency: get_frequency(item),
        user_id: current_user.id,
        google_event_id: item.id,
        location_name: item.location
      )
      @items << item
      if @event.new_record?
        if @event.save
          @calendar.events << @event
        end
      else
        next if public_event(item)
        synchronize_event(item) if !cancelled?(item)
      end

      if @frequence && @event.persisted?
        calculate_event_recurrence
      end
      create_event_cancellation(item) if cancelled?(item)
      @frequence = nil if @frequence
    end
  end

  def synchronize_event(item)
    event = Event.find_by_google_event_id(item.id)
    puts "EVENT UPDATED AT #{event.try(:updated_at)}"
    puts "ITEM UPDATED AT #{item.try(:updated)} - CALENDAR_ID - #{@calendar.title}- ID #{item.id} title #{item.summary}"
    if event.updated_at <= item.updated
      event.update_attributes(
        starts_at: start_date(item),
        ends_at: item.end.date_time,
        timezone_name: item.start.try(:time_zone) || event.timezone_name,
        notes: item.description,
        title: title(item),
        frequency: get_frequency(item),
        user_id: current_user.id,
        google_event_id: item.id,
        location_name: item.location
      )
      puts 'LOCAL EVENT HAS BEEN UPDATED'
    else
      google_event = @service.get_event(@calendar.title, event.google_event_id)
      google_event.update!(
        # params here
      )
      @service.update_event(@calendar.title, event.google_event_id, google_event)
      puts 'GOOGLE EVENT HAS BEEN UPDATED'
    end
  end

  def test_summary(event)
    if event.summary
      event.summary + '!'
    else
      '!'
    end
  end

  def public_event(item)
    item.visibility == 'public'
  end

  def create_event_cancellation(item)
    EventCancellation.find_or_create_by(
      event_id: @event.id,
      date: item.original_start_time.date_time.to_date
    )
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
    days = @frequence[:BYDAY].split(',')
    days.map do |day|
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

  %w(token auth).each do |method|
    define_method "google_#{method}_uri" do
      google_oauth2_path + '/' + method
    end
  end

  def google_oauth2_path
    'https://accounts.google.com/o/oauth2'
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
    if cancelled?(item)
      item.original_start_time.date_time
    else
      item.start.date || item.start.date_time
    end
  end

  def title(item)
    if cancelled?(item)
      Event.find_by_google_event_id(item.recurring_event_id).title || 'No title'
    else
      item.summary || 'No title'
    end
  end

  def cancelled?(item)
    item.status == 'cancelled'
  end

  def set_client
    @client = Signet::OAuth2::Client.new({
      authorization_uri: google_auth_uri,
      token_credential_uri: google_token_uri,
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      code: params[:code],
      expires_in: 604800,
      expiry: 604800,
      client_id: Rails.application.secrets.google_client_id,
      client_secret: Rails.application.secrets.google_client_secret,
      redirect_uri: url_for(:action => :oauth2callback)
    })
  end

end
