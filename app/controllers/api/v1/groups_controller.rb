class Api::V1::GroupsController < ApiController
  include Swagger::Blocks

  before_filter :find_entity, except: [:index, :create]
  authorize_resource
  check_authorization

  def index
    @groups = current_user.groups
  end

  def show
    render partial: 'group', locals: {group: @group }
  end

  def create
    @group = Group.new(group_params)
    @group.owner = current_user


    return render nothing: true, status: :internal_server_error unless @group.save
    render partial: 'group', locals: {group: @group }, status: :created
  end

  def update
    @group.assign_attributes(group_params)


    return render nothing: true, status: :internal_server_error unless @group.save
    render partial: 'group', locals: {group: @group }
  end

  def destroy
    @group.destroy
    render nothing: true, status: :no_content
  end

  private
  def group_params
    params.permit(:title)
  end

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER PATH: Controller Groups
  # ================================================================================

  #swagger_path /groups:
  swagger_path '/groups' do
    operation :get do
      key :summary, 'List of croups created by user'
      key :description, 'Returns a list of groups which were created by user earlier'
      # responses
      response 200 do
        key :description, 'OK'
        schema do
          key :type, :array
          items do
            key :'$ref', '#/definitions/Group'
          end
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response :default
      key :tags, ['User groups']
    end # end operation :get
    operation :post do
      key :summary, 'Creates new group'
      parameter do
        key :name, 'group'
        key :description, 'Group object'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', '#/definitions/GroupInput'
        end
      end
      # responses
      response 201 do
        key :description, 'Created'
        schema do
          key :'$ref', '#/definitions/Group'
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
      key :tags, ['User groups']
    end # end operation :post
  end # end swagger_path /groups:

  # swagger_path /groups/{id}
  swagger_path '/groups/{id}' do
    operation :get do
      key :summary, 'Single group object'
      key :description, 'Returns group object by specified group id'
      parameter do
        key :name, 'id'
        key :in, 'path'
        key :type, :integer
        key :required, true
      end
      # responses
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', '#/definitions/Group'
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response :default
      key :tags, ['User groups']
    end # end operation :get
    operation :put do
      key :summary, 'Updates existing group'
      parameter do
        key :name, 'id'
        key :in, 'path'
        key :type, :integer
        key :required, true
      end
      parameter do
        key :name, 'group'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', '#/definitions/GroupInput'
        end
      end
      # responses
      response 204 do
        key :description, 'OK'
      end # end response 204
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response :default
      key :tags, ['User groups']
    end # end operation :put
    operation :delete do
      key :summary, 'Removes existing group'
      parameter do
        key :name, 'id'
        key :in, 'path'
        key :type, :integer
        key :required, true
      end
      # responses
      response 204 do
        key :description, 'OK'
      end # end response 204
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response :default
      key :tags, ['User groups']
    end # end operation :delete
  end # end swagger_path /groups/{id}

  # swagger_path /groups/{group_id}/users
  swagger_path '/groups/{group_id}/users' do
    operation :get do
      key :summary, 'List of users in group'
      key :description, 'Returns list of users which were added to specified (by group_id) group by current user'
      parameter do
        key :name, 'group_id'
        key :in, 'path'
        key :type, :integer
        key :required, true
      end
      # responses
      response 200 do
        key :description, 'OK'
        schema do
          key :type, :array
          items do
            key :'$ref', '#/definitions/User'
          end
        end
      end # end response 200
      key :tags, ['User groups']
    end # end operation :get
  end # end swagger_path /groups/{group_id}/users

  # swagger_path /groups/{group_id}/users/{user_id}
  swagger_path '/groups/{group_id}/users/{user_id}' do
    operation :post do
      key :summary, 'Adds user to group'
      parameter do
        key :name, 'group_id'
        key :in, 'path'
        key :type, :integer
        key :required, true
      end
      parameter do
        key :name, 'user_id'
        key :in, 'path'
        key :type, :integer
        key :required, true
      end
      # responses
      response 200 do
        key :description, 'OK'
      end # end response 200
      key :tags, ['User groups']
    end # end operation :post
    operation :delete do
      key :summary, 'Delete user to group'
      parameter do
        key :name, 'group_id'
        key :in, 'path'
        key :type, :integer
        key :required, true
      end
      parameter do
        key :name, 'user_id'
        key :in, 'path'
        key :type, :integer
        key :required, true
      end
      # responses
      response 204 do
        key :description, 'OK'
      end # end response 204
      key :tags, ['User groups']
    end # end operation :delete
  end # end swagger_path /groups/{group_id}/users/{user_id}

end
