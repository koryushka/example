class Api::V1::UsersController < ApiController
  include Swagger::Blocks

  before_filter :find_entity, only: [:show, :add_to_group, :remove_from_group]
  before_filter only: [:group_index, :add_to_group, :remove_from_group] do
    find_entity type: :group, id_param: :group_id
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

  def update
    current_user.assign_attributes(user_params)
    if current_user.valid?
      unless current_user.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: current_user.errors.messages }, status: :bad_request
    end

    render partial: 'user', locals: { user: current_user }, status: :created
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
          key :'$ref', '#/definitions/RegistrationInput'
        end
      end
      # responses
      response 200 do
        key :description, 'OK'
      end # end response 200
      response 403 do
        key :description, 'redurect_url is missing or not allowed, or user creation error'
      end # end response 403
      key :tags, ['Users']
    end # end operation :post
  end # end swagger_path /users
  # swagger_path /users/me
  swagger_path '/users/me' do
    operation :get do
      key :summary, 'Current user with profile'
      # responses
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', '#/definitions/User'
        end
      end # end response 200
      response :default do
        key :description, 'Unxpected error'
        schema do
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response :default
      key :tags, ['Users']
    end # end operation :get
  end # end swagger_path /users/me
  # swagger_path /users/me/profile
  swagger_path '/users/me/profile' do
    operation :get do
      key :summary, 'Returns profile of current user'
      # responses
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', '#/definitions/Profile'
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response :default
      key :tags, ['Users']
    end # end operation :get
    operation :put do
      key :summary, 'Updates current user profile'
      parameter do
        key :name, 'profile'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', '#/definitions/ProfileInput'
        end
      end
      # responses
      response 201 do
        key :description, 'OK'
        schema do
          key :'$ref', '#/definitions/Profile'
        end
      end # end response 201
      response 400 do
        key :description, 'Validation error'
        schema do
          key :'$ref', '#/definitions/ValidationError'
        end
      end # end response 400
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response :default
      key :tags, ['Users']
    end # end operation :put
  end # end swagger_path /users/me/profile
  # swagger_path /users/{user_id}/profile
  swagger_path '/users/{user_id}/profile' do
    operation :get do
      key :summary, 'Updates current user profile'
      parameter do
        key :name, 'user_id'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      # responses
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', '#/definitions/Profile'
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response :default
      key :tags, ['Users']
    end # end operation :get
  end # end swagger_path /users/{user_id}/profile

end
