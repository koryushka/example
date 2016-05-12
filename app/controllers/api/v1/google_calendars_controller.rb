class Api::V1::GoogleCalendarsController < ApiController
  skip_before_filter :doorkeeper_authorize!, except: [:remove_account, :import_calendars, :refresh_token, :get_account_info]
  before_action :google_auth, only: [:index, :show, :import_calendars]

  def import_calendars
    items = []
    @accounts.each do |account|
      parser = GoogleCalendars.new(current_user, account)
      parser.import_calendars
      items << parser.items
    end
    render json: {items: items}
  end

  private

  def google_auth
    @accounts = []
    current_user.google_access_tokens.where('deleted IS NOT TRUE').each do |google_access_token|
      refresh_token google_access_token if google_access_token.expired?
      client = Signet::OAuth2::Client.new(access_token: google_access_token.token)
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      @accounts << service
    end
  end
end
