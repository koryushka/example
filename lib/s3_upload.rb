require 'helpers/configuration'
require 'securerandom'

module S3Upload
  extend Configuration

  define_setting :fog_params
  define_setting :bucket, 'uploads'
  define_setting :subdir

  class Uploader

    def save(file)
      filename = SecureRandom.hex(24) + File.extname(file.tempfile)
      filename = "#{S3Upload.subdir}/#{filename}" unless S3Upload.subdir.nil?
      client = Fog::Storage.new(S3Upload.fog_params)
      directory = client.directories.get(S3Upload.bucket)
      directory = client.directories.create(key: S3Upload.bucket) if directory.nil?

      directory.files.create(
          key: filename,
          body: file.tempfile,
          public: true
      )
    end

    # If you're getting "TypeError: can't dup NilClass", it means you haven't specified S3Upload.fog_params yet
    def remove_file(key)
      client = Fog::Storage.new(S3Upload.fog_params)
      directory = client.directories.get(S3Upload.bucket)
      unless directory.nil?
        file = directory.files.get(key)
        file.destroy unless file.nil?
      end
    end
  end
end