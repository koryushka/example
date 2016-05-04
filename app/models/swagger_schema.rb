
class SwaggerSchema
  include Swagger::Blocks

  # swagger_schema :ErrorsContainer
  swagger_schema :ErrorsContainer do
    key :type, :object
    property :errors do
      key :type, :array
      items do
        key :'$ref', '#/definitions/Error'
      end
    end
  end # end swagger_schema :ErrorsContainer

  # swagger_schema :Error
  swagger_schema :Error do
    property :code do
      key :type, :integer
      key :format, :int32
    end
    property :message do
      key :type, :string
    end
  end # end swagger_schema :Error

  # defenition :ValidationErrorsContainer
  swagger_schema :ValidationErrorsContainer do
    key :type, :object
    property :validation_errors do
      key :type, :array
      items do
        key :'$ref', '#/definitions/ValidationError'
      end
    end
  end # end defenition :ValidationErrorsContainer

  # defenition :ValidationError
  swagger_schema :ValidationError do
    key :type, :object
    key :description, 'Name of this field will be the same as the name of model field which has validation errors.
            For example, we have model with invalid email field. In this case we have following error object:
            "validation_errors": {
              "email": [
              "Email address is invalid"
              ]
            }'
    property :error_field_name do
      key :type, :array
      items do
        key :type, :string
      end
    end
  end # defenition :ValidationError
end