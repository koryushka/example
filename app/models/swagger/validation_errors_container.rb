class ValidationErrorsContainer
  include Swagger::Blocks

  swagger_schema :ValidationErrorsContainer do
    key :type, :object
    property :validation_errors do
      key :type, :array
      items do
        key :'$ref', '#/definitions/ValidationError'
      end
    end

  end
end