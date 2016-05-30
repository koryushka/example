class Api::V1::GoogleOauthController < ApiController
  include Swagger::Blocks
  include GoogleAuth
  before_action :set_client, only: [:auth, :oauth2callback]

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
  end

  swagger_path '/oauth2callback' do
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
      # parameter do
      #   key :name, 'expires_in'
      #   key :description, 'Google access_token expiration'
      #   key :in, 'query'
      #   key :required, true
      #   key :type, :integer
      # end

      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', :Account
        end
      end # end response 200
      # responses
      # response 400 do
      #   key :description, 'Validation errors'
      #   schema do
      #     key :'$ref', :ValidationErrorsContainer
      #   end
      # end
      # # response Default
      # response :default do
      #   key :description, 'Unexpected error'
      #   schema do
      #     key :'$ref', :Error
      #   end
      # end # end response Default
      key :tags, ['Accounts']
    end # end operation :get
  end # end swagger_path ':/oauth2callback'


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
  end
end
