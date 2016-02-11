class Api::V1::DocumentsController < ApiController
  before_filter :find_document, except: [:index, :create]

  def index
    @documents = @calendar_item.documents
  end

  def show
    render partial: 'document', locals: { document: @document }
  end

  def create
    @document = Document.new(document_params)
    @document.user = tmp_user
    if @document.valid?
      unless @document.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @document.errors.messages }, status: :bad_request
    end

    render partial: 'document', locals: { document: @document }, status: :created
  end

  def update
    @document.assign_attributes(document_params)

    if @document.valid?
      unless @document.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @document.errors.messages }, status: :bad_request
    end

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

  def find_document
    document_id = params[:id]
    @document = Document.find_by(id: document_id)

    if @document.nil?
      render nothing: true, status: :not_found
    end
  end
end