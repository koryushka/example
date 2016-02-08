require 'helpers/configuration'
require 'securerandom'

module S3Upload
  extend Configuration

  define_setting :fog_params
  define_setting :bucket, 'uploads'
  define_setting :subdir

  class Uploader
    def initialize(file)
      @file = file.tempfile
    end

    def save
      filename = SecureRandom.hex(24) + File.extname(@file)

      unless S3Upload.subdir.nil?
        filename = "#{S3Upload.subdir}/#{filename}"
      end

      client = Fog::Storage.new(S3Upload.fog_params)
      directory = client.directories.get(S3Upload.bucket)

      if directory.nil?
        directory = client.directories.create(key: S3Upload.bucket)
      end

      directory.files.create(
          key: filename,
          body: @file,
          public: true
      )
    end
  end
end