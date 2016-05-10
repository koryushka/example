class Api::V1::UsersController < ApiController
  include Swagger::Blocks

  before_filter :find_entity, only: [:show, :add_to_group, :remove_from_group]
  before_filter only: [:group_index, :add_to_group, :remove_from_group] do
    find_entity type: :group, id_param: :group_id
  end

  swagger_path '/users/me' do
    operation :get do
      key :summary, 'Current user with profile'
      # responses
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', :User
        end
      end # end response 200
      response :default do
        key :description, 'Unxpected error'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['Users']
    end # end operation :get
  end
  def me
    render partial: 'user', locals: { user: current_user }, status: :created
  end

  def show
    @user = User.find_by_id(params[:id])

    if @user.nil?
      render json: {errors: [{message: "User not found #{params[:id]}", code: 404}]}, :status => :not_found
    end
  end

  # Group members
  def group_index
    @members = @group.members
  end

  def add_to_group
    @group.members << @user
    render nothing: true
  end

  def remove_from_group
    @group.members.delete(@user)
    render nothing: true, status: :no_content
  end

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER PATH: Controller Users
  # ================================================================================

  # swagger_path /users
  swagger_path '/users' do
    operation :post do
      key :summary, 'Registers user'
      key :description, 'Email registration. Requires email, password, and password_confirmation params.
A verification email will be sent to the email address provided.'
      parameter do
        key :name, 'data'
        key :in, 'body'
        schema do
          key :'$ref', :RegistrationInput
        end
      end
      # responses
      response 200 do
        key :description, 'OK'
      end # end response 200
      response 403 do
        key :description, 'redirect_url is missing or not allowed, or user creation error'
      end # end response 403
      key :tags, ['Users']
    end # end operation :post
    operation :put do
      key :summary, "Updates user's data (password, email)"
      key :description, "Updates user's data (password, email). For updating password current_password field is required"
      parameter do
        key :name, 'data'
        key :in, 'body'
        schema do
          key :'$ref', :UserUpdateInput
        end
      end
      # responses
      response 200 do
        key :description, 'OK'
      end # end response 200
      response 403 do
        key :description, 'Update error'
        schema do
          key :'$ref', '#/definitions/ValidationError'
        end
      end # end response 403
      response 404 do
        key :description, 'User not found'
      end # end response 404
      response 422 do
        key :description, 'Incorrect request body'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end # end response 422
      response :default do
        key :description, 'Unxpected error'
        key :'$ref', :ErrorsContainer
      end # end response :default
      key :tags, ['Users']
    end
  end # end swagger_path /users

  swagger_path 'users/pasword' do
    operation :post do
      key :summary, 'Starts password resetting process'
      key :description, 'Accepts email and redirect_url as params. The user matching the email
param will be sent instructions on how to reset their password.
redirect_url is the url to which the user will be redirected
after visiting the link contained in the email.'
      parameter do
        key :name, 'data'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', :PasswordResetInput
        end
      end
      response 200 do
        key :description, 'OK'
      end
      response 400 do
        key :description, 'Validation error'
        schema do
          key :'$ref', :ValidataionError
        end
      end
      response 404 do
        key :description, 'Unable to find user with given email'
      end
      response :default do
        key :description, 'Unxpected error'
        key :'$ref', :ErrorsContainer
      end
      key :tags, ['Password reset']
    end
    operation :put do
      key :summary, "Updates user's password and finishes password resetting process"
      key :description, "This method changes user's password. It requires values of params:
client_id, token and uid. These params can be obtained when user
clicks on link which were sent after /users/password calling"
      parameter do
        key :name, 'client'
        key :description, 'Value of cleint_id query param should be placed here'
        key :in, 'header'
        key :required, true
        key :type, 'string'
      end
      parameter do
        key :name, 'uid'
        key :description, 'Value of uid query param should be placed here'
        key :in, 'header'
        key :required, true
        key :type, 'string'
      end
      parameter do
        key :name, 'access-token'
        key :description, 'Value of token query param should be placed here'
        key :in, 'header'
        key :required, true
        key :type, 'string'
      end
      parameter do
        key :name, 'data'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', :PasswordChangeInput
        end
      end
      response 200 do
        key :description, 'OK'
      end
      response 400 do
        key :description, 'Validation error'
        schema do
          key :'$ref', :ValidataionError
        end
      end
      response 404 do
        key :description, 'Token is invalid or expired'
      end
      response :default do
        key :description, 'Unxpected error'
        key :'$ref', :ErrorsContainer
      end
      key :tags, ['Password reset']
    end
  end
end

