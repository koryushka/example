class Api::V1::GoogleOauthController < ApiController
  skip_before_filter :doorkeeper_authorize!, except: [:remove_account, :get_account_info]
  before_action :set_client, only: [:auth, :oauth2callback]
  before_action :check_for_params, only: [:remove_account]

  def auth
    redirect_to @client.authorization_uri.to_s
  end

  def oauth2callback
    response = @client.fetch_access_token!
    if refresh_token = response['refresh_token']
      google_access_token = GoogleAccessToken.find_or_create_by(refresh_token: refresh_token) do |t|
        t.token = response['access_token']
        t.expires_at = Time.now + response['expires_in'].to_i
      end
    end
    get_account_info(response)
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

  def remove_account
    account = params[:account]
    remove_events = params[:remove_events]
    google_access_token = current_user.google_access_tokens.find_by_account(account)
    google_access_token.update_column(:deleted, true)
    render json: {params: params}
  end

  private

  def get_account_info(data)
    uri = 'https://www.googleapis.com/oauth2/v1/userinfo?access_token=' + data['access_token']
    response = JSON.parse(open(uri).string)
    if google_access_token = GoogleAccessToken.find_by_account(response['email'])
      google_access_token.update_attributes(
        token: data['access_token'],
        deleted: false
      ) if google_access_token
    elsif google_access_token = GoogleAccessToken.find_by_token(data['access_token'])
      google_access_token.update_attributes(
        account: response['email'],
        user_id: current_user.id
      ) if google_access_token
    end
    render json:{data: response}
  end

  def check_for_params
    errors = []
    errors << 'Account required' if params[:account].blank?
    if( params[:remove_events].blank? && errors.empty?)
      errors << 'Should we remove events connected with this account?'
    end
    if !errors.empty?
      render json: {errors: errors}, status: 403
      return
    end
  end

  %w(token auth).each do |method|
    define_method "google_#{method}_uri" do
      google_oauth2_path + '/' + method
    end
  end

  def google_oauth2_path
    'https://accounts.google.com/o/oauth2'
  end

  def set_client
    @client = Signet::OAuth2::Client.new({
      authorization_uri: google_auth_uri,
      token_credential_uri: google_token_uri,
      scope: [Google::Apis::CalendarV3::AUTH_CALENDAR,'https://www.googleapis.com/auth/userinfo.email'],
      code: params[:code],
      expires_in: 604800,
      expiry: 604800,
      client_id: Rails.application.secrets.google_client_id,
      client_secret: Rails.application.secrets.google_client_secret,
      redirect_uri: url_for(:action => :oauth2callback)
    })
  end
end
