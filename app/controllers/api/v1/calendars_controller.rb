class Api::V1::CalendarsController < ApiController
  #before_filter :authenticate_api_v1_user!
  before_filter :find_calendar, except: [:index, :create]

  def index
    @calendars = tmp_user.calendars
  end

  def show
    render partial: 'calendar', locals: { calendar: @calendar_item }
  end

  def create
    @calendar_item = Calendar.new(calendar_params)
    @calendar_item.user = tmp_user
    if @calendar_item.valid?
      unless @calendar_item.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @calendar_item.errors.messages }, status: :bad_request
    end

    render partial: 'calendar', locals: { calendar: @calendar_item }, status: :created
  end

  def update
    @calendar_item.assign_attributes(calendar_params)

    if @calendar_item.valid?
      unless @calendar_item.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @calendar_item.errors.messages }, status: :bad_request
    end

    render partial: 'calendar', locals: { calendar: @calendar_item }
  end

  def destroy
    @calendar_item.destroy
    render nothing: true, status: :no_content
  end

  private
  def calendar_params
    params.permit(:title, :hex_color, :main, :kind, :visible)
  end

  def find_calendar
    calendar_id = params[:id]
    @calendar_item = Calendar.find_by(id: calendar_id)

    if @calendar.nil?
      render nothing: true, status: :not_found
    end
  end
end