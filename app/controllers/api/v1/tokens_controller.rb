class Api::V1::TokensController < Doorkeeper::TokensController
  include ActionController::StrongParameters
  include Swagger::Blocks

  def create
    @login_data = LoginData.new(auth_params)
    unless @login_data.valid?
      return render json: { validation_errors: @login_data.errors.messages }, status: :bad_request
    end

    super

    server.resource_owner.clean_tokens if server.resource_owner # resource owner is an instance of User model
  end

private

  def auth_params
    params.permit(:username, :password, :refresh_token, :scope, :grant_type)
  end

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER PATH: Controller Tokens
  # ================================================================================
  swagger_path '/oauth/token' do
    # Operation: POST
    # Authenticates user and returns authorization token
    operation :post do
      key :summary, 'Authenticates user'
      key :description, 'Authenticates user and returns authorization token'
      # token parameters
      parameter do
        key :name, 'credentials'
        key :in, 'body'
        schema do
          key :'$ref', '#/definitions/SignInCredentials'
        end
      end # end token parameters
      # Response OK
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', '#/definitions/SignInResponse'
        end
      end # end Response OK
      # Path name Auth
      key :tags, ['Auth']
    end # end operation :post do
  end

  # Definition :SignInCredentials
  swagger_schema :SignInCredentials do
    key :type, :object
    key :required, [:grant_type, :username, :password]
    property :grant_type do
      key :type, :string
      key :description, 'grant type, can be *password* or *refresh_token*'
    end
    property :username do
      key :type, :string
      key :description, "User's email. Required if grant_type is password"
    end
    property :password do
      key :type, :string
      key :description, "User's password. Required if grant_type is password"
    end
    property :scope do
      key :type, :string
      key :description, "Authorisation scope. Can be sent if grant_type is password. = ['user' or 'admin']"
    end
    property :refresh_token do
      key :type, :string
      key :description, "User's refresh token. Required if grant_type is refresh_token"
    end
  end # end Definition :SignInCredentials

  # Definition SignInResponse
  swagger_schema :SignInResponse do
    key :type, :object
    key :required, [:access_token, :token_type, :expires_in, :refresh_token, :scope, :created_at]
    property :access_token do
      key :type, :string
      key :description, 'Uniq access_token'
    end
    property :scope do
      key :type, :string
      key :description, 'Authorisation scope'
    end
    property :refresh_token do
      key :type, :string
      key :description, 'Uniq refresh_token, can be used when access_token expires'
    end
    property :created_at do
      key :type, :string
      key :description, 'date-time'
    end
    property :token_type do
      key :type, :string
      key :description, 'Token type, Default - bearer'
    end
    property :expires_in do
      key :type, :integer
      key :description, 'Access_token expiration in seconds'
    end
  end # end definition SignInResponse
end
