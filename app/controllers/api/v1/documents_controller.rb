class Api::V1::DocumentsController < ApiController
  before_filter :find_entity, except: [:index, :create]
  before_filter only: [:index] do
    find_entity type: :event, id_param: :event_id
  end
  after_filter :something_updated, except: [:index, :show]
  authorize_resource
  check_authorization

  def index
    @documents = @event.documents
  end

  def show
    render partial: 'document', locals: { document: @document }
  end

  def create
    @document = Document.new(document_params)
    @document.user = current_user

    raise InternalServerErrorException unless @document.save
    render partial: 'document', locals: { document: @document }, status: :created
  end

  def update
    @document.assign_attributes(document_params)

    raise InternalServerErrorException unless @document.save
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