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
          body: file.tempfile,
          public: true
      )
    end

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