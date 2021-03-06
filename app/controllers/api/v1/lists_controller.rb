class Api::V1::ListsController < ApiController
  include Swagger::Blocks

  before_filter :find_entity, except: [:index, :create]
  authorize_resource
  check_authorization

  #swagger_path /lists
  swagger_path '/lists' do
    operation :get do
      key :summary, 'Current user lists'
      key :description, 'Returns all lists created by current user or shared with him'
      # responses
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', :ArrayOfLists
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
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
          key :'$ref', :ListInput
        end
      end
      # responses
      response 201 do
        key :description, 'Created'
        schema do
          key :'$ref', :List
        end
      end # end response 201
      response 400 do
        key :description, 'Validation erro'
        schema do
          key :'$ref', :ValidationErrorsContainer
        end
      end # end response 400
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['Lists']
    end # end operation :post
  end # end swagger_path /lists
  def index
    @lists = current_user.lists
                 .includes(:list_items,
                           participations: {
                               user: :profile,
                               sender: :profile
                           })
  end

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
          key :'$ref', :List
        end
      end # end response 201
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['Lists']
    end # end operation :get
  end
  def show
    render partial: 'list', locals: { list: @list }
  end

  def create
    @list = List.new(list_params)
    @list.user = current_user

    raise InternalServerErrorException unless @list.save
    render partial: 'list', locals: { list: @list }, status: :created
  end

  swagger_path '/lists/{id}' do
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
          key :'$ref', :ListInput
        end
      end
      # responses
      response 201 do
        key :description, 'Updated'
        schema do
          key :'$ref', :List
        end
      end # end response 201
      response 400 do
        key :description, 'Validation error'
        schema do
          key :'$ref', :ValidationErrorsContainer
        end
      end # end response 400
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['Lists']
    end
  end
  def update
    @list.assign_attributes(list_params)

    raise InternalServerErrorException unless @list.save
    render partial: 'list', locals: { list: @list }
  end

  swagger_path '/lists/{id}' do
    operation :delete do
      key :summary, 'Delete list'
      key :description, 'Deletes list by ID  and detaches it from event if if was attached earlier'
      parameter do
        key :name, 'id'
        key :description, "List's ID"
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      response 204 do
        key :description, 'Deleted'
      end
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end
      key :tags, ['Lists']
    end
  end
  def destroy

    @list.events.each do |event|
      event.update(list_id: nil)
    end if @list.events.size > 0
    @list.destroy
    render nothing: true, status: :no_content
  end

private
  def list_params
    params.permit(:title, :notes, :kind, :public)
  end

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
            key :'$ref', :Event
          end
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['Lists', 'Events']
    end # end operation :get
  end # end swagger_path /lists/{id}/events

end