class Api::V1::CalendarsController < ApiController
  #before_filter :authenticate_api_v1_user!
  before_filter :find_calendar, except: [:index, :create]
  before_filter :find_calendar_item, only: [:add_item, :remove_item]

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

  def add_item
    @calendar.calendar_items << @calendar_item
    render nothing: true
  end

  def remove_item
    @calendar.calendar_items.delete(@calendar_item)
    render nothing: true, status: :no_content
  end

  def show_items
    @calendar_items = @calendar.calendar_items
    render 'api/v1/calendar_items/index'
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

  def find_calendar_item
    calendar_item_id = params[:item_id]
    @calendar_item = CalendarItem.find_by(id: calendar_item_id)

    if @calendar_item.nil?
      render nothing: true, status: :not_found
    end
  end
end