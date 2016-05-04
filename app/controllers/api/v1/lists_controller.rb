class Api::V1::ListsController < ApiController
  include Swagger::Blocks

  before_filter :find_entity, except: [:index, :create]
  after_filter :something_updated, except: [:index, :show]
  authorize_resource
  check_authorization

  def index
    @lists = current_user.lists.includes(:list_items)
  end

  def show
    render partial: 'list', locals: { list: @list }
  end

  def create
    @list = List.new(list_params)
    @list.user = current_user

    return render nothing: true, status: :internal_server_error unless @list.save
    render partial: 'list', locals: { list: @list }, status: :created
  end

  def update
    @list.assign_attributes(list_params)

    return render nothing: true, status: :internal_server_error unless @list.save
    render partial: 'list', locals: { list: @list }
  end

  def destroy
    @list.destroy
    render nothing: true, status: :no_content
  end

private
  def list_params
    params.permit(:title, :notes, :kind)
  end

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER PATH: Controller Lists
  # ================================================================================
  #swagger_path /lists
  swagger_path '/lists' do
    operation :get do
      key :summary, 'Current user lists'
      key :description, 'Returns all lists created by current user or shared with him'
      # responses
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', '#/definitions/ArrayOfLists'
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/Error'
        end
      end # end response :default
      key :tags, ['Lists']
    end # end operation :get
    operation :post do
      key :summary, 'Create list'
      key :description, 'Creates new list'
      parameter do
        key :name, 'list'
        key :description, 'List object'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', '#/definitions/ListInput'
        end
      end
      # responses
      response 201 do
        key :description, 'Created'
        schema do
          key :'$ref', '#/definitions/List'
        end
      end # end response 201
      response 400 do
        key :description, 'Validation erro'
        schema do
          key :'$ref', '#/definitions/ValidationError'
        end
      end # end response 400
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/Error'
        end
      end # end response :default
      key :tags, ['Lists']
    end # end operation :post
  end # end swagger_path /lists
  # swagger_path /lists/{id}
  swagger_path '/lists/{id}' do
    operation :get do
      key :summary, 'Returns list object'
      parameter do
        key :name, 'id'
        key :description, "List's ID"
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      # responses
      response 201 do
        key :description, 'Updated'
        schema do
          key :'$ref', '#/definitions/List'
        end
      end # end response 201
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/Error'
        end
      end # end response :default
      key :tags, ['Lists']
    end # end operation :get
    operation :put do
      key :summary, 'Updates list information by ID'
      parameter do
        key :name, 'id'
        key :description, "List's ID"
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, 'list'
        key :description, 'List object'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', '#/definitions/ListInput'
        end
      end
      # responses
      response 201 do
        key :description, 'Updated'
        schema do
          key :'$ref', '#/definitions/List'
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
          key :'$ref', '#/definitions/Error'
        end
      end # end response :default
      key :tags, ['Lists']
    end # end operation :put
    operation :delete do
      key :summary, 'Delete list'
      key :description, 'Deletes list by ID'
      parameter do
        key :name, 'id'
        key :description, "List's ID"
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      # responses
      response 204 do
        key :description, 'Deleted'
      end # end response 204
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/Error'
        end
      end # end response :default
      key :tags, ['Lists']
    end # end operation :delete
  end # end /lists/{id}
  # swagger_path /lists/{id}/events
  swagger_path '/lists/{id}/events' do
    operation :get do
      key :summary, 'Show events'
      key :description, 'Returns all events which have list specified by id'
      parameter do
        key :name, 'id'
        key :description, "List's ID"
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      # responses
      response 200 do
        key :description, 'OK'
        schema do
          key :type, :array
          items do
            key :'$ref', '#/definitions/Event'
          end
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/Error'
        end
      end # end response :default
      key :tags, ['Lists', 'Events']
    end # end operation :get
  end # end swagger_path /lists/{id}/events

end