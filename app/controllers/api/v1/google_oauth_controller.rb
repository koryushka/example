class Api::V1::GoogleOauthController < ApiController
  include Swagger::Blocks
  include GoogleAuth
  before_filter :set_client, only: [:auth, :oauth2callback]
  before_filter :check_for_tokens, only: [:google_oauth]

  def google_oauth
    access_token = @access_token || params[:access_token]
    refresh_token = params[:refresh_token]
    begin
      uri = ACCOUNT_INFO_URI + access_token
      response = JSON.parse(open(uri).string)
      email = response['email']
    rescue OpenURI::HTTPError => error
      gat = GoogleAccessToken.find_by(refresh_token: refresh_token, user_id: current_user.id)
      if gat
        refresh_token gat
        @access_token = gat.token
        google_oauth
        return
      end
      render json: {message: error.message, code: error.io.status[0]}, status: error.io.status[0]
      return
    end
    manage_google_access_tokens(email)
    GoogleSyncService.new.sync current_user.id
    render json: google_oauth_response(email)
  end

  def google_oauth_response(email)
    {
      info: "Account #{email} has been successfully added to user #{current_user.email}",
      access_token: @access_token
    }
  end

  swagger_path '/google_oauth' do
    operation :get do
      key :summary, 'Add google account'
      key :description, 'Updates calendar information by ID'
      parameter do
        key :name, 'access_token'
        key :description, 'Google access token'
        key :in, 'query'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, 'refresh_token'
        key :description, 'Google refresh token'
        key :in, 'query'
        key :required, true
        key :type, :string
      end
      response 401 do
        key :description, 'Unauthorized'
        schema do
          key :'$ref', :Error
        end
      end
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', :AccessToken
        end
      end # end response 200
      key :tags, ['Accounts']
    end # end operation :get
  end # end swagger_path ':/oauth2callback'

  #These endpoints are used for development
  def auth
    redirect_to @client.authorization_uri.to_s
  end

  def oauth2callback
    @response = params[:code] ? @client.fetch_access_token! : params
    if refresh_token = @response['refresh_token']
      @google_access_token = GoogleAccessToken.new(
        refresh_token: refresh_token,
        token: @response['access_token'],
        expires_at: Time.now + 3500#@response['expires_in'].to_i
      )
    end
    get_account_info(@response)
  end #end of development methods

  private

  def manage_google_access_tokens(email)
    if google_access_token = GoogleAccessToken.find_by(account: email,
                                                       user_id: current_user.id)
      google_access_token.update_columns(google_token_params(google_access_token))
    elsif GoogleAccessToken.new(google_token_params.merge({
            user_id: current_user.id,
            account: email,
            expires_at: Time.now + 3500
            })
          ).save!
    end
  end

  def google_token_params(google_access_token = nil)
    parameters = {
      refresh_token: params[:refresh_token],
      token: params[:access_token],
      revoked: false,
      synchronizable: true
    }
  end

  def check_for_tokens
    errors = []
    errors << 'Access token required' if params[:access_token].blank?
    errors << 'Refresh token required' if params[:refresh_token].blank?
    unless errors.empty?
      render json: {errors: errors}, status: 401
      return
    end

  end

  #These endpoints are used for development
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
    render json:{response: @response}
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
  end #end of development methods

end
