class Api::V1::EventsController < ApiController
  before_filter :find_entity, except: [:index, :create]
  before_filter :find_document, only: [:attach_document, :detach_document]
  after_filter :something_updated, except: [:index, :show, :show_documents]
  #authorize_resource
  #check_authorization

  def index
    @events = current_user.events
  end

  def show
    render partial: 'event', locals: {event: @event }
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user
    if @event.valid?
      unless @event.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @event.errors.messages }, status: :bad_request
    end

    render partial: 'event', locals: {event: @event }, status: :created
  end

  def update
    @event.assign_attributes(event_params)

    if @event.valid?
      unless @event.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @event.errors.messages }, status: :bad_request
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

  def show_documents
    @documents = @event.documents
    render 'api/v1/documents/index'
  end

private
  def event_params
    params.permit(:title, :starts_at, :ends_at, :notes, :kind, :latitude,
                  :longitude, :location_name, :separation, :count, :until,
                  :timezone_name, :frequency,
                  event_recurrences_attributes: [:day, :week, :month],
                  event_cancelation_attributes: [:date])
  end

  def find_document
    document_id = params[:document_id]
    @document = Document.find_by(id: document_id)

    if @document.nil?
      render nothing: true, status: :not_found
    end
  end
end