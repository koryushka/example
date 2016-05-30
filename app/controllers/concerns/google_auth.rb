module GoogleAuth

  GOOGLE_OAUTH2_PATH = 'https://accounts.google.com/o/oauth2'
  ACCOUNT_INFO_URI =   'https://www.googleapis.com/oauth2/v1/userinfo?access_token='
  EMAIL_SCOPE =        'https://www.googleapis.com/auth/userinfo.email'

  %w(token auth).each do |method|
    define_method "google_#{method}_uri" do
      GOOGLE_OAUTH2_PATH + '/' + method
    end
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
    if token_has_been_revoked?(body)
      google_access_token.revoke!
    else
      google_access_token.update_attributes(
        token: body['access_token'],
        expires_at: Time.now + body['expires_in'].to_i
      )
    end
  end

  def authorize(google_access_token)
    refresh_token google_access_token if (google_access_token.expired? && !google_access_token.revoked?)
    client = Signet::OAuth2::Client.new(access_token: google_access_token.token)
    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.authorization = client
  end

  def bad_request?(request)
    request.class == Net::HTTPBadRequest
  end

  def token_has_been_revoked?(body)
    body['error_description'] == "Token has been revoked."
  end

end
