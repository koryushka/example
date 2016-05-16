class Api::V1::GroupsController < ApiController
  include Swagger::Blocks

  before_filter :find_entity, except: [:index, :create]
  authorize_resource
  check_authorization

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
            key :'$ref', :Group
          end
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['User groups']
    end
  end
  def index
    #@groups = current_user.groups.includes(participations: :sender)
    @groups = [current_user.family]
  end

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
          key :'$ref', :Group
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['User groups']
    end
  end
  def show
    render partial: 'group', locals: {group: @group }
  end

  swagger_path '/groups' do
    operation :post do
      key :summary, 'Creates new group'
      parameter do
        key :name, 'group'
        key :description, 'Group object'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', :GroupInput
        end
      end
      # responses
      response 201 do
        key :description, 'Created'
        schema do
          key :'$ref', :Group
        end
      end # end response 201
      response 400 do
        key :description, 'Validation error'
        schema do
          key :'$ref', :ValidationErrorsContainer
        end
      end
      response 409 do
        key :description, 'You cannot create new group being other group member or owner'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['User groups']
    end
  end
  def create
    creation_forbidden = current_user.groups.size > 0 ||
        current_user.participations.exists?(participationable_type: Group.name)
    raise UnableCreateGroupException if creation_forbidden

    @group = Group.new(group_params)
    @group.owner = current_user

    raise InternalServerErrorException unless @group.save
    render partial: 'group', locals: {group: @group }, status: :created
  end

  swagger_path '/groups/{id}' do
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
          key :'$ref', :GroupInput
        end
      end
      # responses
      response 204 do
        key :description, 'OK'
      end # end response 204
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['User groups']
    end
  end
  def update
    @group.update(group_params)
    render partial: 'group', locals: {group: @group }
  end

  swagger_path '/groups/{id}' do
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
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['User groups']
    end
  end
  def destroy
    @group.destroy
    render nothing: true, status: :no_content
  end

  swagger_path '/groups/{id}/leave' do
    operation :delete do
      key :summary, 'Removes current user from group'
      parameter do
        key :name, 'id'
        key :description, 'Group ID'
        key :in, 'path'
        key :type, :integer
        key :required, true
      end
      # responses
      response 200 do
        key :description, 'OK'
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['User groups']
    end # end operation :delete
  end
  def leave
    participation = @group.participations.where(user: current_user)
    @group.participations.delete(participation)
    render nothing: true
  end

private
  def group_params
    params.permit(:title)
  end
end
