class Api::V1::CalendarsController < ApiController
  before_filter :find_entity, except: [:index, :create]
  before_filter only: [:add_event, :remove_event] do
    find_entity type: :event, id_param: :event_id
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

    raise InternalServerErrorException unless @calendar.save
    render partial: 'calendar', locals: { calendar: @calendar }, status: :created
  end

  def update
    @calendar.assign_attributes(calendar_params)

    raise InternalServerErrorException unless @calendar.save
    render partial: 'calendar', locals: { calendar: @calendar }
  end

  def destroy
    @calendar.destroy
    render nothing: true, status: :no_content
  end

  def add_event
    @calendar.events << @event
    render nothing: true
  end

  def remove_event
    @calendar.events.delete(@event)
    render nothing: true, status: :no_content
  end

  def show_items
    @events = query_params[:since].nil? ? @calendar.events : @calendar.events.where('events.updated_at > ?', query_params[:since])
    #@shared_events = query_params[:since].nil? ? @calendar.shared_events : @calendar.shared_events.where('events.updated_at > ?', query_params[:since])
    @shared_events = []
    render 'items'
  end

private
  def calendar_params
    params.permit(:title, :hex_color, :main, :kind, :visible)
  end

  def query_params
    params.permit(:since)
  end
end