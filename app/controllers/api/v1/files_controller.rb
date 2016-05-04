class Api::V1::FilesController < ApiController
  include Swagger::Blocks

  before_filter except: [:create] do
    find_entity type: :uploaded_file, id_param: :id, property_name: :file
  end
  after_filter :something_updated, except: [:show]
  #authorize_resource
  #check_authorization

  def show
    render partial: 'file', locals: { file: @file }
  end

  def create
    uploader = S3Upload::Uploader.new
    file = uploader.save(params[:file])

    return render text: 'Uploading error', status: :internal_server_error unless file

    @file = UploadedFile.new public_url: file.public_url, key: file.key
    @file.save

    render partial: 'file', locals: { file: @file }
  end

  def destroy
    @file.destroy!
    render nothing: true, status: :no_content
  end

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER PATH: Controller Files
  # ================================================================================
  # swagger_path /files
  swagger_path '/files' do
    operation :post do
      key :summary, 'Accepts files'
      key :description, 'Accept files and sends them to storage'
      key :consumes, '[multipart/form-data]'
      parameter do
        key :name, 'file'
        key :description, 'binary file'
        key :in, 'formData'
        key :required, true
        key :type, :file
      end
      #responses
      response 201 do
        key :description, 'Created'
        schema do
          key :'$ref', '#/definitions/File'
        end
      end # end response 201
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/Error'
        end
      end # end response Default
      key :tags, ['Files']
    end # end operation :post
  end # end /files
  # swagger_path /files/{id}
  swagger_path '/files/{id}' do
    operation :get do
      key :summary, 'Returns information about file by its ID'
      parameter do
        key :name, 'id'
        key :description, "File's ID"
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      #responses
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', '#/definitions/File'
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/Error'
        end
      end # end response Default
      key :tags, ['Files']
    end # end operation :get
    operation :delete do
      key :summary, 'Removes file'
      parameter do
        key :name, 'id'
        key :description, "File's ID"
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      #responses
      response 204 do
        key :description, 'Detached'
      end # end response 204
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/Error'
        end
      end # end response Default
      key :tags, ['Files']
    end # end operation :delete
  end # end swagger_path /files/{id}



end