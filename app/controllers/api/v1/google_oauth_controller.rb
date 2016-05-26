class Api::V1::GoogleOauthController < ApiController
  include GoogleAuth
  before_action :set_client, only: [:auth, :oauth2callback]

  def auth
    redirect_to @client.authorization_uri.to_s
  end

  def oauth2callback
    response = @client.fetch_access_token!
    if refresh_token = response['refresh_token']
      @google_access_token = GoogleAccessToken.new(
        refresh_token: refresh_token,
        token: response['access_token'],
        expires_at: Time.now + response['expires_in'].to_i
      )
    end
    get_account_info(response)
  end

  private

  def get_account_info(data)
    uri = ACCOUNT_INFO_URI + data['access_token']
    response = JSON.parse(open(uri).string)
    if google_access_token = GoogleAccessToken.find_by(account: response['email'],
                                                       user_id: current_user.id)
      if @google_access_token
        GoogleAccessToken.where(account: response['email'])
        .update_all(refresh_token: data['refresh_token'], revoked: false)
      end
        google_access_token.update_attributes(
          google_access_token_params(data)
        )
    else
      if google_access_token = GoogleAccessToken.find_by(account: response['email'])
        GoogleAccessToken.new(google_access_token
                              .attributes
                              .except('id', 'created_at', 'updated_at', 'synchronizable')
                              .merge({user_id: current_user.id}))
                              .save
      else
        @google_access_token.update_attributes(account: response['email'],
                                               user_id: current_user.id)
      end
    end
    GoogleSyncService.new.sync current_user.id
    render json:{message: "Import completed"}
  end

  def google_access_token_params(data)
    {
      token: data['access_token'],
      revoked: false
    }
  end

  def set_client
    @client = Signet::OAuth2::Client.new({
      authorization_uri: google_auth_uri,
      token_credential_uri: google_token_uri,
      scope: [
        Google::Apis::CalendarV3::AUTH_CALENDAR,
        EMAIL_SCOPE
      ],
      code: params[:code],
      client_id: Rails.application.secrets.google_client_id,
      client_secret: Rails.application.secrets.google_client_secret,
      redirect_uri: url_for(:action => :oauth2callback)
    })
  end
end
