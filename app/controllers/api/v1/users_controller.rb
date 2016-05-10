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
    operation 'put' do
      key :summary, "Updates user's data (password, email)"
      key :description, "Updates user's data (password, email). For updating password current_password field is required"
      parameter do
        key :name, 'data'
        key :in, 'body'
        schema do
          key :'$ref', '#/definitions/UserUpdateInput'
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
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response 422
      response :default do
        key :description, 'Unxpected error'
        key :'$ref', '#/definitions/ErrorsContainer'
      end # end response :default
      key :tags, ['Users']
    end

  end # end swagger_path /users
end

