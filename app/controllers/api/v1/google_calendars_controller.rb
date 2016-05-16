class Api::V1::GoogleCalendarsController < ApiController
  before_action :google_auth, only: [:sync]
  before_action :check_for_params, only: [:unsync_calendar, :sync_calendar]
  before_action :set_calendar, only: [:unsync_calendar, :sync_calendar]

  def sync
    items = []
    google_events_ids = []
    @accounts.each do |service|
      account = account(service.authorization.access_token)
      parser = GoogleCalendars.new(current_user, service, account)
      parser.import_calendars
      items << parser.items
      parser.items.each { |item| google_events_ids << item.id }
      local_events = Event.where('google_event_id is not NULL and events.user_id = ?', current_user.id)
        .includes(:calendar)
        .where(calendars: {sync_with_google: true})
      result = local_events.pluck(:google_event_id) - google_events_ids
      compare_events(result)
    end
    render json: {items: items}
  end

  def remove_calendars(account)
    google_access_token = GoogleAccessToken.find_by_account account
    authorize google_access_token
    calendars_list = @service.list_calendar_lists.items.map {|calendar| calendar.id}
    calendars = Calendar.where('google_calendar_id in (?) AND account = ?', calendars_list, account)
    calendars.destroy_all
  end

  def unsync_calendar
    @calendar.unsync! if @calendar
    render nothing: true
  end

  def sync_calendar
    @calendar.sync! if @calendar
    render nothing: true
  end

  private

  def compare_events(result)
    result.each do |e|
      event = Event.find_by_google_event_id(e)
      event.destroy if event
    end
  end

  def check_for_params
    errors = []
    %w(calendar account).each do |a|
      errors << "Set #{a}" if params[a.to_sym].blank?
    end
    unless errors.empty?
      render json: {errors: errors}, status: 403
      return
    end
  end

  def set_calendar
    @calendar = Calendar.find_by(title: params[:calendar], account: params[:account])
  end

  def account(access_token)
    uri = account_info_uri + access_token
    response = JSON.parse(open(uri).string)
    response['email']
  end

  def google_auth
    @accounts = []
    current_user.google_access_tokens.where('deleted IS NOT true').each do |google_access_token|
      authorize google_access_token
      @accounts << @service
    end
  end

  # def authorize(google_access_token)
  #   puts "AUTHORIZATION"
  #   @google_oauth ||= Api::V1::GoogleOauthController.new
  #   puts "google oauth #{@google_oauth}"
  #   @google_oauth.refresh_token google_access_token if google_access_token.expired?
  #   @client = Signet::OAuth2::Client.new(access_token: google_access_token.token)
  #   @service ||= Google::Apis::CalendarV3::CalendarService.new
  #   @service.authorization = @client
  # end
end
