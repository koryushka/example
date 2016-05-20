class Api::V1::GoogleCalendarsController < ApiController
  include Googleable
  before_action :google_auth, only: [:sync]
  before_action :check_for_params, only: [:unsync_calendar, :sync_calendar]
  before_action :set_calendar, only: [:unsync_calendar, :sync_calendar]

  # action should be removed from controller
  def sync
    items = []
    google_events_ids = []
    @accounts.each do |service|
      account = account(service.authorization.access_token)
      parser = GoogleCalendars.new(current_user, service, account)
      parser.import_calendars
      items << parser.items
      parser.items.each { |item| google_events_ids << item.id }
      local_events_ids = Event.where('google_event_id IS NOT NULL AND events.user_id = ?', current_user.id)
        .includes(:calendar)
        .where(calendars: {sync_with_google: true})
        .pluck(:google_event_id)
      compare_events(local_events_ids, google_events_ids)
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

  def compare_events(local_events_ids, google_events_ids)
    result = local_events_ids - google_events_ids
    Event.where('google_event_id in (?)', result).destroy_all
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
    @calendar = Calendar.find_by(title: params[:calendar], account: params[:account], user_id: current_user.id)
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

end
