class Api::V1::FilesController < ApiController
  before_filter :find_file, except: [:create]

  def show
    render partial: 'file', locals: { file: @file }
  end

  def create
    uploader = S3Upload::Uploader.new
    file = uploader.save(params[:file])

    return render text: 'Uploading error', status: :internal_server_error unless file

    @file = UploadedFile.new public_url: file.public_url, key: file.key
    @file.save!

    render :show
  end

  def destroy
    @file.destroy!
    render nothing: true, status: :no_content
  end

private
  def find_file
    file_id = params[:id]
    @file = UploadedFile.find_by(id: file_id)

    if @file.nil?
      render nothing: true, status: :not_found
    end
  end
end