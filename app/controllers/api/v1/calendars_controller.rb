class Api::V1::CalendarsController < ApiController
  before_filter :find_entity, except: [:index, :create]
  before_filter only: [:add_item, :remove_item] do
    find_entity type: :event, id_param: :item_id
  end
  after_filter :something_updated, except: [:index, :show, :show_items]
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
    @calendar.events << @event
    render nothing: true
  end

  def remove_item
    @calendar.events.delete(@event)
    render nothing: true, status: :no_content
  end

  def show_items
    render 'items'
  end

  private
  def calendar_params
    params.permit(:title, :hex_color, :main, :kind, :visible)
  end
end