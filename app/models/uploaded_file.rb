class UploadedFile < ActiveRecord::Base
  mount_uploader :file, FileUploader
  before_destroy :remove_file!

  validates :file, is_uploaded: true
  validates :file, filename_uniqueness: true
end
