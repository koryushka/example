class Api::V1::ListItemsController < ApiController
  include Swagger::Blocks

  before_filter :find_entity, except: [:index, :create]
  before_filter do
    find_entity_of_current_user type: :list, id_param: :list_id
  end
  before_filter only: [:assign, :unassign] do
    find_entity type: :user
  end
  after_filter :something_updated, except: [:index, :show]
  authorize_resource
  check_authorization

  def index
    @list_items = @list.list_items
  end

  def show
    render partial: 'list_item', locals: { list_item: @list_item }
  end

  def create
    @list_item = ListItem.new(list_item_params)
    @list_item.list = @list
    @list_item.user = current_user

    raise InternalServerErrorException unless @list_item.save
    render partial: 'list_item', locals: { list_item: @list_item }, status: :created
  end

  def update
    @list_item.assign_attributes(list_item_params)

    raise InternalServerErrorException unless @list_item.save
    render partial: 'list_item', locals: { list_item: @list_item }
  end

  def destroy
    @list_item.destroy
    render nothing: true, status: :no_content
  end

  def assign

  end

  def unassign

  end

private
  def list_item_params
    params.permit(:title, :notes, :done, :order)
  end

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER PATH: Controller list items
  # ================================================================================

  # swagger_path /lists/{id}/items
  swagger_path '/lists/{id}/items' do
    operation :get do
      key :summary, 'List items'
      key :description, 'Returns all items in specific list by list ID'
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
          key :'$ref', :ArrayOfListItems
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['List Items', 'Lists']
    end # end operation :get
    operation :post do
      key :summary, 'Create list item'
      key :description, 'Creates new list item in specific list by list ID'
      parameter do
        key :name, 'id'
        key :description, "List's ID"
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, 'list_item'
        key :description, 'Item object which should be added to list'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', :ListItemInput
        end
      end
      # responses
      response 201 do
        key :description, 'Created'
        schema do
          key :'$ref', :ListItem
        end
      end # end response 201
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['List Items', 'Lists']
    end # end operation :post
  end # end swagger_path /lists/{id}/items

  # swagger_path /lists/{list_id}/items/{id}
  swagger_path '/lists/{list_id}/items/{id}' do
    operation :get do
      key :summary, 'Shows list item'
      key :description, 'Returns single list item data'
      parameter do
        key :name, 'list_id'
        key :description, 'List ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, 'id'
        key :description, 'List item ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      # responses
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', :ListItem
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['List Items', 'Lists']
    end # end operation :get
    operation :put do
      key :summary, 'Update list item'
      key :description, 'Updates list item information by list ID and item ID'
      parameter do
        key :name, 'list_id'
        key :description, 'List ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, 'id'
        key :description, 'List item ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, 'list_item'
        key :description, 'Updated list item object'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', :ListItemInput
        end
      end
      # responses
      response 201 do
        key :description, 'Updated'
        schema do
          key :'$ref', :ListItem
        end
      end # end response 201
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['List Items', 'Lists']
    end # end operation :put
    operation :delete do
      key :summary, 'Delete list item'
      key :description, 'Deletes list item by item ID'
      parameter do
        key :name, 'list_id'
        key :description, 'List ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, 'id'
        key :description, 'List item ID'
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
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['List Items', 'Lists']
    end # end operation :delete
  end # end swagger_path /lists/{list_id}/items/{id}

end
