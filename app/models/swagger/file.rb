
class File
  include Swagger::Blocks

  swagger_schema :File do
    key :type, :object
    property :id do
      key :type, :integer
      key :description, 'File identifier'
    end
    property :public_url do
      key :type, :string
      key :description, 'URL of file. You can use it for file downloading'
    end
  end
end