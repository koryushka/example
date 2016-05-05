
class SwaggerSchema
  include Swagger::Blocks

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER SCHEMA: Error Models and Participation
  # ================================================================================

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

  # swagger_schema :Participation
  swagger_schema :Participation do
    key :type, :object
    property :identifier do
      key :type, :string
      key :description, 'Calendar item ID'
    end
    property :participant do
      key :type, :string
      key :description, 'User ID with whom to share'
    end
    property :sharedBy do
      key :type, :string
      key :description, 'User ID who shares'
    end
    property :startDate do
      key :type, :string
      key :format, 'date-time'
      key :description, 'Optional start date and time for share'
    end
    property :endDate do
      key :type, :string
      key :format, 'date-time'
      key :description, 'Optional end date and time for share'
    end
    property :readOnly do
      key :type, :boolean
      key :description, 'Specifies if this is read only share'
      key :default, true
    end
    property :sharedItem do
      key :type, :object
      key :description, 'Item to be shared. It should be only one item - calendar, calendar group, calendar item,
document or list'
      property :calendar do
        key :type, :string
        key :description, 'Optional calendar ID to be shared'
      end
      property :calendarGroup do
        key :type, :string
        key :description, 'Optional calendar group ID to be shared'
      end
      property :calendarItem do
        key :type, :string
        key :description, 'Optional calendar item ID to be shared'
      end
      property :document do
        key :type, :string
        key :description, 'Optional document ID to be shared'
      end
      property :list do
        key :type, :string
        key :description, 'Optional list ID to be shared'
      end
    end
  end # end swagger_schema :Participation

  # swagger_schema :ArrayOfParticipations
  swagger_schema :ArrayOfParticipations do
    key :type, :array
    items do
      key :'$ref', '#/definitions/Participation'
    end
  end # swagger_schema :ArrayOfParticipations

   # swagger_schema :SharingItem
  swagger_schema :SharingItem do
    key :type, :object
    property :id do
      key :type, :integer
    end
    property :subject_class do
      key :type, :string
      key :description, 'Type of sharing entity for example: Calendar, Event, etc.'
    end
    property :subject_id do
      key :type, :integer
      key :description, 'ID of entity which should be shared'
    end
    property :user_id do
      key :type, :integer
      key :description, "ID of user you're going to share with"
    end
  end # end swagger_schema :SharingItem

  # swagger_schema :SharingInput
  swagger_schema :SharingInput do
    key :type, :object
    property :subject_class do
      key :type, :string
      key :description, 'Type of sharing entity for example: Calendar, Event, etc.'
    end
    property :subject_id do
      key :type, :integer
      key :description, 'ID of entity which should be shared'
    end
    property :user_id do
      key :type, :integer
    end
  end # end swagger_schema :SharingInput

end
