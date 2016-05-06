class Api::V1::ProfilesController < ApiController
  before_filter only: [:show, :update] do
    @user = current_user
    find_entity type: :user, id_param: :user_id unless params[:user_id].blank?
    render text: "Could not find profile for user id: '#{@user.id}'", status: :not_found if @user.profile.nil?
    @profile = @user.profile
  end
  authorize_resource
  check_authorization

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
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['Users']
    end # end operation :get
  end # end swagger_path /users/{user_id}/profile
  def show
    render partial: 'profile', locals: {profile: @profile}
  end

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
          key :'$ref', :ErrorsContainer
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
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['Users']
    end # end operation :put
  end # end swagger_path /users/me/profile
  def my_profile
    render partial: 'profile', locals: {profile: current_user.profile}
  end

  def update
    @profile.assign_attributes(profile_params)

    return render nothing: true, status: :internal_server_error unless @profile.save
    render partial: 'profile', locals: {profile: @profile}
  end

private
  def profile_params
    params.permit(:first_name, :last_name, :image_url, :color)
  end
end
