# ================================================================================
# Swagger::Blocks
# Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
# SWAGGER SCHEMA: Error
# ================================================================================
class Error
  include Swagger::Blocks
  swagger_schema :Error do
    key :type, :object
    property :code do
      key :type, :integer
      key :format, :int32
    end
    property :message do
      key :type, :string
    end
  end # end swagger_schema :Error
end