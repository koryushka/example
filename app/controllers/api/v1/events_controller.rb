class Api::V1::EventsController < ApiController
  before_filter :find_entity, except: [:index, :create]
  before_filter only: [:attach_document, :detach_document] do
    find_entity type: :document, id_param: :document_id
  end
  after_filter :something_updated, except: [:index, :show]
  authorize_resource
  check_authorization

  def index
    @events = current_user.events.includes(:event_cancellations, :event_recurrences)
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

    render partial: 'event', locals: {event: @event }, status: :created
  end

  def update
    @event.assign_attributes(event_params)

    unless @event.save
      return render nothing: true, status: :internal_server_error
    end

    render partial: 'event', locals: {event: @event }
  end

  def destroy
    @event.destroy
    render nothing: true, status: :no_content
  end

  def attach_document
    @event.documents << @document
    render partial: 'event', locals: {event: @event }
  end

  def detach_document
    @event.documents.delete(@document)
    render nothing: true, status: :no_content
  end

private
  def event_params
    params.permit(:title, :starts_at, :ends_at, :notes, :kind, :latitude,
                  :longitude, :location_name, :separation, :count, :until,
                  :timezone_name, :frequency,
                  event_recurrences_attributes: [:day, :week, :month],
                  event_cancelations_attributes: [:date])
  end
end