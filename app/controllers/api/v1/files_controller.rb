class Api::V1::FilesController < ApiController

  def create
    @file = UploadedFile.new params[:file]
  end
end