class Api::V1::CalendarItemsController < ApiController
  #before_filter :authenticate_api_v1_user!
  before_filter :find_calendar_item, except: [:index, :create]
  before_filter :find_document, only: [:attach_document, :detach_document]
  authorize_resource
  check_authorization
  after_filter :something_updated, except: [:index, :show, :show_documents]

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

  def attach_document
    @calendar_item.documents << @document
    render partial: 'calendar_item', locals: { calendar_item: @calendar_item }
  end

  def detach_document
    @calendar_item.documents.delete(@document)
    render nothing: true, status: :no_content
  end

  def show_documents
    @documents = @calendar_item.documents
    render 'api/v1/documents/index'
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

  def find_document
    document_id = params[:document_id]
    @document = Document.find_by(id: document_id)

    if @document.nil?
      render nothing: true, status: :not_found
    end
  end
end