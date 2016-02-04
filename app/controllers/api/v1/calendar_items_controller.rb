class Api::V1::CalendarItemsController < ApiController
  #before_filter :authenticate_api_v1_user!
  before_filter :find_calendar_item, except: [:index, :create]

  def index
    @calendar_items = tmp_user.calendar_items
  end

  def show
    render partial: 'calendar_item', locals: { calendar_item: @calendar_item }
  end

  def create
    @calendar_item = CalendarItem.new(calendar_item_params)
    @calendar_item.user = tmp_user
    if @calendar_item.valid?
      unless @calendar_item.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @calendar_item.errors.messages }, status: :bad_request
    end

    render partial: 'calendar_item', locals: { calendar_item: @calendar_item }, status: :created
  end

  def update
    @calendar_item.assign_attributes(calendar_item_params)

    if @calendar_item.valid?
      unless @calendar_item.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @calendar_item.errors.messages }, status: :bad_request
    end

    render partial: 'calendar_item', locals: { calendar_item: @calendar_item }
  end

  def destroy
    @calendar_item.destroy
    render nothing: true, status: :no_content
  end

private
  def calendar_item_params
    params.permit(:title, :start_date, :end_date, :notes, :kind, :latitude, :longitude, :location_name)
  end

  def find_calendar_item
    calendar_item_id = params[:id]
    @calendar_item = CalendarItem.find_by(id: calendar_item_id)

    if @calendar_item.nil?
      render nothing: true, status: :not_found
    end
  end
end