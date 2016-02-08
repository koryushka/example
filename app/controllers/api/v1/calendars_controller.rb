class Api::V1::CalendarsController < ApiController
  #before_filter :authenticate_api_v1_user!
  before_filter :find_calendar, except: [:index, :create]

  def index
    @calendars = tmp_user.calendars
  end

  def show
    render partial: 'calendar', locals: { calendar: @calendar }
  end

  def create
    @calendar = Calendar.new(calendar_params)
    @calendar.user = tmp_user
    if @calendar.valid?
      unless @calendar.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @calendar.errors.messages }, status: :bad_request
    end

    render partial: 'calendar', locals: { calendar: @calendar }, status: :created
  end

  def update
    @calendar.assign_attributes(calendar_params)

    if @calendar.valid?
      unless @calendar.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @calendar.errors.messages }, status: :bad_request
    end

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

  def find_calendar
    calendar_id = params[:id]
    @calendar = Calendar.find_by(id: calendar_id)

    if @calendar.nil?
      render nothing: true, status: :not_found
    end
  end
end