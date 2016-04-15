class Api::V1::DocumentsController < ApiController
  before_filter :find_entity, except: [:index, :event_index, :create]
  before_filter only: [:event_index] do
    find_entity type: :event, id_param: :event_id
  end
  after_filter :something_updated, except: [:index, :event_index, :show]
  authorize_resource
  check_authorization

  def index
    @documents = current_user.documents
  end

  def event_index
    @documents = @event.documents
    render :index
  end

  def show
    render partial: 'document', locals: { document: @document }
  end

  def create
    @document = Document.new(document_params)
    @document.user = current_user

    return render nothing: true, status: :internal_server_error unless @document.save
    render partial: 'document', locals: { document: @document }, status: :created
  end

  def update
    @document.assign_attributes(document_params)

    return render nothing: true, status: :internal_server_error unless @document.save
    render partial: 'document', locals: { document: @document }, status: :created
  end

  def destroy
    @document.destroy
    render nothing: true, status: :no_content
  end

private
  def document_params
    params.permit(:title, :uploaded_file_id, :notes, :tags)
  end
end