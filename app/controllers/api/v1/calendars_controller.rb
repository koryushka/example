class Api::V1::CalendarsController < ApiController
  before_filter :find_entity, except: [:index, :create]
  after_filter :something_updated, except: [:index, :show]
  authorize_resource
  check_authorization

  include Swagger::Blocks

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
  swagger_path '/calendars' do
    # Operation: GET
    # Returns all calendars created by current user or shared with him
    operation :get do
      key :summary, 'Current user calendars'
      key :description, 'Returns all calendars created by current user or shared with him'
      # Response OK
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', '#/definitions/ArrayOfCalendars'
        end
      end # end response OK
      # Response Default
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response Default
      # Path name Calendars
      key :tags, ['Calendars']
    end
  end # end swagger_path '/calendars'

  # Definition ErrorsContainer
  swagger_schema :ErrorsContainer do
    key :type, :object
    property :errors do
      key :type, :array
      items do
        key :'$ref', '#/definitions/ErrorModel'
      end
    end
  end # end swagger_schema :ErrorsContainer

end