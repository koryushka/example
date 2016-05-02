class Api::V1::CalendarsGroupsController < ApiController
  include Swagger::Blocks

  before_filter :find_entity, except: [:index, :create]
  authorize_resource
  check_authorization
  after_filter :something_updated, except: [:index, :show]

  def index
    @groups = current_user.calendars_groups
  end

  def show
    render partial: 'group', locals: { group: @calendars_group }
  end

  def create
    @calendars_group = CalendarsGroup.new(calendars_group_params)
    @calendars_group.user = current_user

    return render nothing: true, status: :internal_server_error unless @calendars_group.save
    render partial: 'group', locals: { group: @calendars_group }, status: :created
  end

  def update
    @calendars_group.assign_attributes(calendars_group_params)

    return render nothing: true, status: :internal_server_error unless @calendars_group.save
    render partial: 'group', locals: { group: @calendars_group }, status: :created
  end

  def destroy
    @calendars_group.destroy
    render nothing: true, status: :no_content
  end

private
  def calendars_group_params
    params.permit(:title)
  end

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER PATH: Controller Calendar Group
  # ================================================================================
  swagger_path '/calendars_groups' do
    operation :get do
      key :summary, 'Current user calendar groups'
      key :description, 'Returns all calendar groups created by current user or shared with him'
      # Response OK
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', '#/definitions/ArrayOfCalendarGroups'
        end
      end # end response OK
      # Response Default
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/ErrorModel'
        end
      end # end response Default
      key :tags, ['Calendar Groups']
    end # end operation GET
    operation :post do
      key :summary, 'Create calendar group'
      key :description, 'Creates new calendar group'
      parameter do
        key :name, 'calendars_group'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', '#/definitions/CalendarsGroupInput'
        end
      end
      # responses
      response 201 do
        key :description, 'Created'
        schema do
          key :'$ref', '#/definitions/CalendarsGroup'
        end
      end # end response 201
      response 400 do
        key :description, 'Validation errors'
        schema do
          key :'$ref', '#/definitions/ValidationErrorsContainer'
        end
      end # end response 400
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/Error'
        end
      end # end response Default
      key :tags, ['Calendar Groups']
    end # end operation :post
  end # end swagger_path '/calendars_groups'
  # swagger_path '/calendars_groups/{id}'
  swagger_path '/calendars_groups/{id}' do
    operation :put do
      key :summary, 'Update calendar group'
      key :description, 'Updates calendar group information by ID'
      parameter do
        key :name, 'id'
        key :description, 'Calendars group ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, 'calendars_group'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', '#/definitions/CalendarsGroupInput'
        end
      end
      # responses
      response 201 do
        key :description, 'Updated'
        schema do
          key :'$ref', '#/definitions/CalendarsGroup'
        end
      end # end response 201
      response 400 do
        key :description, 'Validation errors'
        schema do
          key :'$ref', '#/definitions/ValidationErrorsContainer'
        end
      end # end response 400
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/Error'
        end
      end # end response Default
      key :tags, ['Calendar Groups']
    end # end operation :put
    # operation :delete
    operation :delete do
      key :summary, 'Delete calendar group'
      key :description, 'Deletes calendar group by ID'
      parameter do
        key :name, 'id'
        key :description, 'Calendars group ID'
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
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response Default
      key :tags, ['Calendar Groups']
    end # end operation :delete
  end # end swagger_path '/calendars_groups/{id}'

  # defenition :ValidationErrorsContainer
  swagger_schema :ValidationErrorsContainer do
    key :type, :object
    property :validation_errors do
      key :type, :array
      items do
        key :'$ref', '#/definitions/ValidationError'
      end
    end
  end # end # defenition :ValidationErrorsContainer
  # defenition :ValidationError
  swagger_schema :ValidationError do
    key :type, :object
    key :description, 'Name of this field will be the same as the name of model field which has validation errors.
            For example, we have model with invalid email field. In this case we have following error object:
            "validation_errors": {
              "email": [
              "Email address is invalid"
              ]
            }'
    property :error_field_name do
      key :type, :array
      items do
        key :type, :string
      end
    end
  end # defenition :ValidationError
end