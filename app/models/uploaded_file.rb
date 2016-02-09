class UploadedFile < ActiveRecord::Base
  has_one :document

  validates :public_url, presence: true,  length: {maximum: 2048}
  validates :key, presence: true,  length: {maximum: 512}

  before_destroy :remove_file

private
  def remove_file
    uploader = S3Upload::Uploader.new
    uploader.remove_file(key)
  end
end
