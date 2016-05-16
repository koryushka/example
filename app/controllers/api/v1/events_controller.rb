class Api::V1::EventsController < ApiController
  before_filter :find_entity, except: [:index, :create, :index_of_calendar, :index_of_list]
  before_filter only: [:add_to_calendar, :remove_from_calendar, :index_of_calendar] do
    find_entity_of_current_user type: :calendar, id_param: :calendar_id
  end
  before_filter only: [:add_list, :remove_list, :index_of_list] do
    find_entity_of_current_user type: :list, id_param: :list_id
  end
  after_filter :something_updated, except: [:index, :show, :index_of_calendar, :index_of_list]
  authorize_resource
  check_authorization

  def index
    @events = current_user.events.with_muted(current_user.id).includes(:event_cancellations, :event_recurrences)
  end

  def show
    render partial: 'event', locals: {event: @event }
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user

    unless @event.save
      return render nothing: true, status: :internal_server_error
    end

    MutedEvent.create(user_id: current_user.id, event_id: @event.id, muted: params[:muted]) if params[:muted].present?
    render partial: 'event', locals: {event: @event }, status: :created
  end

  def update
    @event.assign_attributes(event_params)

    unless @event.save
      return render nothing: true, status: :internal_server_error
    end

    MutedEvent.create(user_id: current_user.id, event_id: @event.id, muted: params[:muted]) if params[:muted].present?
    render partial: 'event', locals: {event: @event }
  end

  def destroy
    if @event.destroy && @event.etag
      calendar = @event.calendar
      google_access_token = GoogleAccessToken.find_by_account(calendar.account)
      if google_access_token && calendar.should_be_synchronised?
        authorize google_access_token
        begin
          @service.delete_event(calendar.google_calendar_id, @event.google_event_id)
        rescue Google::Apis::ClientError => error
        end  
      end
    end
    render nothing: true, status: :no_content
  end

  def add_to_calendar
    @calendar.events << @event
    render nothing: true
  end

  def remove_from_calendar
    @calendar.events.delete(@event)
    render nothing: true, status: :no_content
  end

  def index_of_calendar
    @events = @calendar.events.with_muted(current_user.id)
    @events = @events.where('events.updated_at > ?', query_params[:since]) if query_params[:since].present?
    #@shared_events = query_params[:since].nil? ? @calendar.shared_events : @calendar.shared_events.where('events.updated_at > ?', query_params[:since])
    @shared_events = []
  end

  def add_list
    @event.list = @list
    @event.save
    render nothing: true
  end

  def remove_list
    @event.list = nil
    @event.save
    render nothing: true, status: :no_content
  end

  def index_of_list
    @events = @list.events.with_muted(current_user.id)
    render 'index'
  end

  def mute
    me = @event.muted_events.where(muted_events: {user_id: current_user.id}).first
    if me.present? && !me.muted?
      me.muted = true
      me.save
    else
      MutedEvent.create(event: @event, user: current_user, muted: true)
    end

    render nothing: true
  end

  def unmute
    me = @event.muted_events.where(muted_events: {user_id: current_user.id}).first
    if me.present? && me.muted?
      me.muted = false
      me.save
    end

    render nothing: true
  end

private
  def event_params
    params.permit(:title, :starts_at, :ends_at, :all_day, :notes,
                  :kind, :latitude, :longitude, :location_name, :separation,
                  :count, :until, :timezone_name, :frequency,
                  event_recurrences_attributes: [:day, :week, :month],
                  event_cancelations_attributes: [:date])
  end

  def query_params
    params.permit(:since)
  end
end
