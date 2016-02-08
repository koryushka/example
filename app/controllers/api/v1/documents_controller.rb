class Api::V1::DocumentsController < ApiController
  before_filter :find_document, except: [:index, :create]

  def index

  end

  def show

  end

  def create

  end

  def update

  end

  def destroy

  end

private
  def document_params
    params.permit(:title)
  end

  def find_document
    document_id = params[:id]
    @document = Document.find_by(id: document_id)

    if @document.nil?
      render nothing: true, status: :not_found
    end
  end
end