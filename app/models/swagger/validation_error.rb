class ValidationError
  include Swagger::Blocks

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
  end
end