# ================================================================================
# Swagger::Blocks
# Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
# SWAGGER SCHEMA: ErrorsContainer
# ================================================================================
class ErrorsContainer
  include Swagger::Blocks
  # Definition ErrorsContainer
  swagger_schema :ErrorsContainer do
    key :type, :object
    property :errors do
      key :type, :array
      items do
        key :'$ref', '#/definitions/Error'
      end
    end
  end # end swagger_schema :ErrorsContainer
end