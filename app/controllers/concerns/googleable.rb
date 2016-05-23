module Googleable
  %w(token auth).each do |method|
    define_method "google_#{method}_uri" do
      google_oauth2_path + '/' + method
    end
  end

  def google_oauth2_path
    'https://accounts.google.com/o/oauth2'
  end

  def account_info_uri
    'https://www.googleapis.com/oauth2/v1/userinfo?access_token='
  end

  def refresh_token(google_access_token)
    uri = google_token_uri
    data = {
      grant_type: 'refresh_token',
      refresh_token: google_access_token.refresh_token,
      client_id: Rails.application.secrets.google_client_id,
      client_secret: Rails.application.secrets.google_client_secret,
    }
    request = Net::HTTP.post_form(URI.parse(uri), data)
    body = JSON.parse(request.body)
    google_access_token.update_attributes(
      token: body['access_token'],
      expires_at: Time.now + body['expires_in'].to_i
    )
  end

  def authorize(google_access_token)
    refresh_token google_access_token if google_access_token.expired?
    @client = Signet::OAuth2::Client.new(access_token: google_access_token.token)
    @service ||= Google::Apis::CalendarV3::CalendarService.new
    @service.authorization = @client
  end
end
