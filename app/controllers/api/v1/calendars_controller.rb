class Api::V1::CalendarsController < ApiController
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
    @calendar.assign_attributes(calendar_parclass Api::V1::CalendarsController < ApiController
    before_filter :find_entity, except: [:index, :create]
    after_filter :something_updated, except: [:index, :show]
    authorize_resource
    check_authorization

    include Swagger::Blocks
    swagger_path '/calendars' do
      operation :get do
        key :summary, 'Current user calendars'
        key :description, 'Returns all calendars created by current user or shared with him'
        response 200 do
          key :description, 'OK'
          schema do
            key :'$ref', '#/definitions/ArrayOfCalendars'
          end
        end
        response :default do
          key :description, 'Unexpected error'
          schema do
            key :'$ref', '#/definitions/ErrorsContainer'
          end
        end
        key :tags, 'Calendars'
      end
    end


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
    endams)

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
end