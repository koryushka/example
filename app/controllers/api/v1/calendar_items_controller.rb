class Api::V1::CalendarItemsController < ApiController
  before_filter :find_entity, except: [:index, :create]
  before_filter :find_document, only: [:attach_document, :detach_document]
  after_filter :something_updated, except: [:index, :show, :show_documents]
  #authorize_resource
  #check_authorization

  def index
    @calendar_items = current_user.calendar_items
  end

  def show
    render partial: 'calendar_item', locals: { calendar_item: @calendar_item }
  end

  def create
    @calendar_item = CalendarItem.new(calendar_item_params)
    @calendar_item.user = current_user
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

  def find_document
    document_id = params[:document_id]
    @document = Document.find_by(id: document_id)

    if @document.nil?
      render nothing: true, status: :not_found
    end
  end
end