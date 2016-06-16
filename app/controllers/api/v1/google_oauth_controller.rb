class Api::V1::GoogleOauthController < ApiController
  include Swagger::Blocks
  include GoogleAuth
  before_filter :set_client, only: [:auth, :oauth2callback]
  before_filter :check_for_tokens, only: [:google_oauth]
  before_filter :authorize_user_from_query_params, only: [:auth]

  # iOS endpoint
  def google_oauth
    # access_token = @access_token || params[:access_token]
    refresh_token = params[:refresh_token]
    @current_user_id = current_user.id
    begin
      # uri = ACCOUNT_INFO_URI + access_token
      # response = JSON.parse(open(uri).string)
      # email = response['email']
      email
    rescue OpenURI::HTTPError => error
      gat = GoogleAccessToken.find_by(refresh_token: refresh_token, user_id: @current_user_id)
      if gat
        refresh_token! gat
        @access_token = gat.token
        google_oauth
        return
      end
      render json: {message: error.message, code: error.io.status[0]}, status: error.io.status[0]
      return
    end
    manage_google_access_tokens
    # GoogleSyncService.new.sync @current_user_id
    GoogleWorker.perform_async @current_user_id
    render json: google_oauth_response
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

  #These endpoints are used for web app
  def auth
    redirect_to @client.authorization_uri(prompt: 'consent').to_s
    cookies[:token] = params[:token]
    cookies[:redirect_url] = params[:redirect_url]
    cookies[:redirect_path] = params[:redirect_path]
  end

  def oauth2callback
    render nothing: true, status: 401 and return unless current_user_id(cookies[:token])
    cookies.delete(:token)
    unless access_denied?
      @response = @client.fetch_access_token!
      # if refresh_token = @response['refresh_token']
      #   @google_access_token = GoogleAccessToken.new(
      #     refresh_token: refresh_token,
      #     token: @response['access_token'],
      #     expires_at: Time.now + 3500#@response['expires_in'].to_i
      #   )
      # end
      manage_google_access_tokens
      # GoogleSyncService.new.sync @current_user_id
      GoogleWorker.perform_async @current_user_id
      # render json: {response: @response}
      # get_account_info
    end
    host = cookies[:redirect_url] || Rails.application.secrets.host
    path = cookies[:redirect_path] || Rails.application.secrets.path
    redirect_to [host, path].join('#/')
    delete_cookies(:redirect_url, :redirect_path)
  end

  private

  def access_denied?
    params[:error].present?
  end

  def delete_cookies(*args)
    args.each {|cookie| cookies.delete(cookie)}
  end



  # def account_info
  #   refresh_token = @response['refresh_token']
  #   access_token  = @response['access_token']
  #   expitration   = Time.now.utc + 3500
  #   @google_access_token = GoogleAccessToken.find_or_initialize_by(user_id: @current_user_id, account_name: email) do |token|
  #     token.refresh_token = refresh_token
  #     token.token         = access_token
  #     token.expires_at    = expitration
  #   end
  #   if @google_access_token.new_record?
  #     @google_access_token.save
  #   else
  #     @google_access_token.update_attributes(refresh_token: refresh_token, token: access_token, expires_at: expitration)
  #   end
  #
  # end

  def email
    uri = ACCOUNT_INFO_URI + access_token
    response = JSON.parse(open(uri).string)
    @email = response['email']
  end

  def access_token
    @access_token || params[:access_token] || @response['access_token']
  end

  def get_refresh_token
    params[:refresh_token] || @response['refresh_token']
  end

  def unauth_actions
    [:auth, :oauth2callback]
  end

  def authorize_user_from_query_params
    return unless token_present?
    render nothing: true, status: 401 and return unless current_user_id(params[:token])
  end

  def current_user_id(token)
    doorkeeper_token = Doorkeeper::AccessToken.find_by(token: token, revoked_at: nil)
    @current_user_id = doorkeeper_token.try(:resource_owner_id)
  end

  def token_present?
    if params[:token].blank?
      render json: {error: 'Token required'}, status: 401
      false
    else
      true
    end
  end

  def manage_google_access_tokens
    if google_access_token = GoogleAccessToken.find_by(account_name: email,
                                                       user_id: @current_user_id)
      google_access_token.update_columns(google_token_params)
    elsif google_access_token = GoogleAccessToken.new(google_token_params.merge({
            user_id: @current_user_id,
            account_name: email,
            expires_at:  Time.now.utc + 2700
            })
          ).save!
    end
  end

  def google_token_params
    parameters = {
      refresh_token: get_refresh_token,
      token: access_token,
      revoked: false,
      synchronizable: true
    }
  end

  def google_oauth_response
    {
      info: "Account #{@email} has been successfully added to user #{current_user.email}",
      access_token: @access_token
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

  #These endpoints are used for web app
  # def get_account_info#(data)
  #   uri = ACCOUNT_INFO_URI + @response['access_token']
  #   response = JSON.parse(open(uri).string)
  #   if google_access_token = GoogleAccessToken.find_by(account_name: response['email'],
  #                                                      user_id: @current_user_id)
  #     if @google_access_token
  #       GoogleAccessToken.where(account_name: response['email'])
  #       .update_all(refresh_token: @response['refresh_token'], revoked: false)
  #     end
  #       google_access_token.update_attributes(
  #         google_access_token_params#(data)
  #       )
  #   else
  #     if google_access_token = GoogleAccessToken.find_by(account_name: response['email'])
  #       GoogleAccessToken.new(google_access_token
  #                             .attributes
  #                             .except('id', 'created_at', 'updated_at', 'synchronizable')
  #                             .merge({user_id: @current_user_id}))
  #                             .save
  #     else
  #       @google_access_token.update_attributes(account_name: response['email'],
  #                                              user_id: @current_user_id)
  #     end
  #   end
  #   GoogleSyncService.new.sync @current_user_id
  #   render json:{response: @response}
  # end

  def google_access_token_params#(data)
    {
      token: @response['access_token'],
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
