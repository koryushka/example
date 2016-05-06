class Api::V1::CalendarsController < ApiController
  include Swagger::Blocks

  before_filter :find_entity, except: [:index, :create]
  after_filter :something_updated, except: [:index, :show]
  authorize_resource
  check_authorization


  def index
    @calendars = current_user.calendars
  end

  def show
    render partial: 'calendar', locals: { calendar: @calendar }
  end

  def create
    @calendar = Calendar.new(calendar_params)
    @calendar.user = current_user

    return render nothing: true, status: :internal_server_error unless @calendar.save
    render partial: 'calendar', locals: { calendar: @calendar }, status: :created
  end

  def update
    @calendar.assign_attributes(calendar_params)

    return render nothing: true, status: :internal_server_error unless @calendar.save
    render partial: 'calendar', locals: { calendar: @calendar }
  end

  def destroy
    @calendar.destroy
    render nothing: true, status: :no_content
  end
private
  def calendar_params
    params.permit(:title, :hex_color, :main, :kind, :visible)
  end

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER PATH: Controller Calendars
  # ================================================================================

  # swagger_path /calendars
  swagger_path '/calendars' do
    operation :get do
      key :summary, 'Current user calendars'
      key :description, 'Returns all calendars created by current user or shared with him'
      # responses
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', '#/definitions/ArrayOfCalendars'
        end
      end # end response 200
      # response :default
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['Calendars']
    end # end operation :get
    # operation :post
    operation :post do
      key :summary, 'Create calendar'
      key :description, 'Creates new calendar'
      parameter do
        key :name, 'calendar'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', '#/definitions/CalendarInput'
        end
      end
      # responses
      response 201 do
        key :description, 'Created'
        schema do
          key :'$ref', '#/definitions/Calendar'
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
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['Calendars']
    end # end operation :post
  end # end swagger_path '/calendars'

  # swagger_path :/calendars/{id}
  swagger_path '/calendars/{id}' do
    operation :put do
      key :summary, 'Update calendar'
      key :description, 'Updates calendar information by ID'
      parameter do
        key :name, 'id'
        key :description, 'Calendar ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, 'calendar'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', '#/definitions/CalendarInput'
        end
      end
      # responses
      response 201 do
        key :description, 'Updated'
        schema do
          key :'$ref', '#/definitions/CalendarInput'
        end
      end # end response OK
      response 400 do
        key :description, 'Validation errors'
        schema do
          key :'$ref', '#/definitions/ValidationErrorsContainer'
        end
      end
      # response Default
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end # end response Default
      key :tags, ['Calendars']
    end # end operation :put
    operation :delete do
      key :summary, 'Delete calendar'
      key :description, 'Deletes calendar by ID'
      parameter do
        key :name, 'id'
        key :description, 'Calendars ID'
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
      end # end response default
      key :tags, ['Calendars']
    end # end operation :delete
  end # end swagger_path ':/calendars/{id}'

  # swagger_path /calendars/{id}/events
  swagger_path '/calendars/{id}/events' do
    operation :get do
      key :summary, 'Returns items of specified calendar'
      parameter do
        key :name, 'id'
        key :description, 'Calendars ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, 'since'
        key :description, 'Date and time which is bein used for abtaining updates'
        key :in, 'query'
        key :type, :string
        key :format, 'date-time'
      end
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', '#/definitions/EventsContainer'
        end
      end
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end # end response default
      key :tags, ['Events', 'Calendars']
    end # end operation :get
  end # end swagger_path /calendars/{id}/events

  # swagger_path /calendars/{id}/events/{event_id}
  swagger_path '/calendars/{id}/events/{event_id}' do
    operation :post do
      key :summary, 'Add specified event to specified calendar'
      parameter do
        key :name, 'id'
        key :description, 'Calendars ID'
        key :in, 'path'
        key :required, 'true'
        key :type, :integer
      end
      parameter do
        key :name, 'event_id'
        key :description, 'ID of event which should be added'
        key :in, 'path'
        key :required, 'true'
        key :type, :integer
      end
      # responses
      response 200 do
        key :description, 'OK'
      end
      response 406 do
        key :description, 'Impossible to event to the same calendar twice'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end # end response default
      key :tags, ['Events', 'Calendars']
    end # end operation :post
    operation :delete do
      key :summary, 'Removed specified event from specified calendar'
      parameter do
        key :name, 'id'
        key :description, 'Calendars ID'
        key :in, 'path'
        key :required, 'true'
        key :type, :integer
      end
      parameter do
        key :name, 'event_id'
        key :description, 'ID of event which should be removed'
        key :in, 'path'
        key :required, 'true'
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
      end # end response default
      key :tags, ['Events', 'Calendars']
    end # end operation :delete
  end # end swagger_path :/calendars/{id}/events/{event_id}

end
