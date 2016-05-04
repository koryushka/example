class UploadedFile < ActiveRecord::Base
  include Swagger::Blocks

  has_one :document

  validates :public_url, presence: true,  length: {maximum: 2048}
  validates :key, presence: true,  length: {maximum: 512}

  before_destroy :remove_file

private
  def remove_file
    uploader = S3Upload::Uploader.new
    uploader.remove_file(key)
  end

  # swagger_schema :File
  swagger_schema :File do
    key :type, :object
    property :id do
      key :type, :integer
      key :description, 'File identifier'
    end
    property :public_url do
      key :type, :string
      key :description, 'URL of file. You can use it for file dwonloading'
    end

  end # end swagger_schema :File


end
