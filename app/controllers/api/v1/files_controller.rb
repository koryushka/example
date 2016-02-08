class Api::V1::FilesController < ApiController

  def create
    uploader = S3Upload::Uploader.new
    file = uploader.save(params[:file])

    return render text: 'Uploading error', status: :internal_server_error unless file

    @file = UploadedFile.new public_url: file.public_url, key: file.key
    @file.save!

    render :show
  end
end