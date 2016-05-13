class Api::V1::GoogleCalendarsController < ApiController
  # before_action :google_auth, only: [:sync]

  def sync
    google_auth
    items = []
    @accounts.each do |service|
      account = account(service.authorization.access_token)
      parser = GoogleCalendars.new(current_user, service, account)
      parser.import_calendars
      items << parser.items
    end
    render json: {items: items}
  end

  def remove_calendars(account)
    google_access_token = GoogleAccessToken.find_by_account account
    authorize google_access_token
    calendars_list = @service.list_calendar_lists.items.map {|calendar| calendar.id}
    calendars = Calendar.where('title in (?) AND account = ?', calendars_list, account)
    ActiveRecord::Base.transaction do
      calendars.each do |calendar|
        calendar.events.each do |event|
          event.destroy
        end
        calendar.destroy
      end
    end
  end

  private

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

  def authorize(google_access_token)
    @google_oauth ||= Api::V1::GoogleOauthController.new
    @google_oauth.refresh_token google_access_token if google_access_token.expired?
    @client = Signet::OAuth2::Client.new(access_token: google_access_token.token)
    @service ||= Google::Apis::CalendarV3::CalendarService.new
    @service.authorization = @client
  end
end
