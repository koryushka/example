class Api::V1::FilesController < ApiController

  def create
    uploader = S3Upload::Uploader.new(params[:file])
    file = uploader.save

    render json: file.public_url
  end
end