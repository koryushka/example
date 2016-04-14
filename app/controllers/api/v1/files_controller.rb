class Api::V1::FilesController < ApiController
  before_filter except: [:create] do
    find_entity type: :uploaded_file, id_param: :id, property_name: :file
  end
  after_filter :something_updated, except: [:show]
  #authorize_resource
  #check_authorization

  def show
    render partial: 'file', locals: { file: @file }
  end

  def create
    uploader = S3Upload::Uploader.new
    file = uploader.save(params[:file])

    return render text: 'Uploading error', status: :internal_server_error unless file

    @file = UploadedFile.new public_url: file.public_url, key: file.key
    @file.save

    render partial: 'file', locals: { file: @file }
  end

  def destroy
    @file.destroy!
    render nothing: true, status: :no_content
  end
end