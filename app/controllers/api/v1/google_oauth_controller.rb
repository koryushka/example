class Api::V1::GoogleOauthController < ApiController
  include Googleable
  skip_before_filter :doorkeeper_authorize!, except: [:remove_account, :get_account_info, :auth]
  before_action :set_client, only: [:auth, :oauth2callback]
  before_action :check_for_params, only: [:remove_account]

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

  def remove_account
    account = params[:account]
    google_access_token = current_user.google_access_tokens.find_by_account(account)
    google_access_token.update_column(:deleted, true)
    Api::V1::GoogleCalendarsController.new.remove_calendars(account)
    render json: {params: params}
  end

  private

  def get_account_info(data)
    uri = account_info_uri + data['access_token']
    response = JSON.parse(open(uri).string)
    if google_access_token = GoogleAccessToken.find_by(account: response['email'],
                                                       user_id: current_user.id)
      if @google_access_token
        google_access_token.update_attributes(
          token: data['access_token'],
          refresh_token: data['refresh_token'],
          deleted: false
        )
      else
        google_access_token.update_attributes(
          token: data['access_token'],
          deleted: false
        )
      end
    else
      if google_access_token = GoogleAccessToken.find_by(account: response['email'])
        GoogleAccessToken.new(google_access_token
                              .attributes
                              .except('id', 'created_at', 'updated_at', 'deleted')
                              .merge({user_id: current_user.id}))
                              .save
      else
        @google_access_token.update_attributes(account: response['email'],
                                               user_id: current_user.id)
      end
    end

    render json:{data: response}
  end

  def check_for_params
    if params[:account].blank?
      render json: {errors: 'Account required'}, status: 403
      return
    end
  end

  # %w(token auth).each do |method|
  #   define_method "google_#{method}_uri" do
  #     google_oauth2_path + '/' + method
  #   end
  # end
  #
  # def google_oauth2_path
  #   'https://accounts.google.com/o/oauth2'
  # end

  def set_client
    @client = Signet::OAuth2::Client.new({
      authorization_uri: google_auth_uri,
      token_credential_uri: google_token_uri,
      scope: [
        Google::Apis::CalendarV3::AUTH_CALENDAR,
        'https://www.googleapis.com/auth/userinfo.email'
      ],
      code: params[:code],
      client_id: Rails.application.secrets.google_client_id,
      client_secret: Rails.application.secrets.google_client_secret,
      redirect_uri: url_for(:action => :oauth2callback)
    })
  end
end
