class UploadedFile < ActiveRecord::Base
  before_destroy :remove_file
  validates :public_url, presence: true,  length: {maximum: 2048}
  validates :key, presence: true,  length: {maximum: 512}

private
  def remove_file
    S3Upload.new
  end
end
