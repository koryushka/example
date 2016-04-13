class Api::V1::EventCancellationsController < ApiController
  before_filter only:[:create] do
    find_entity type: :event, id_param: :event_id
  end
  before_filter :find_entity, except: [:create]

  def create
    @event_cancellation = EventCancellation.new(event_cancellation_params)
    @event_cancellation.event = @event

    return render nothing: true, status: :internal_server_error unless @event_cancellation.save
    render partial: 'event_cancellation', locals: {event_cancellation: @event_cancellation }, status: :created
  end

  def update
    @event_cancellation.assign_attributes(event_cancellation_params)

    return render nothing: true, status: :internal_server_error unless @event_cancellation.save
    render partial: 'event_cancellation', locals: {event_cancellation: @event_cancellation }
  end

  def destroy
    @event_cancellation.destroy
    render nothing: true, status: :no_content
  end

private
  def event_cancellation_params
    params.permit(:date)
  end
end