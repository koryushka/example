class Api::V1::ApidocsController < ActionController::Base
  include Swagger::Blocks

  swagger_root do
    key :swagger, '2.0'
    info do
      key :version, '1.3.0'
      key :title, 'Curago API'
      key :description, 'API documentation for Curago'
    end

    key :schemes, ['http']
    key :basePath, '/api/v1'
    key :produces, ['application/json']
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
      TokensController,
      CalendarsGroupsController,
      CalendarsGroup,
      CalendarsController,
      Calendar,
      EventsController,
      Event,
      FilesController,
      File,
      ListItemsController,
      # ValidationError,
      # ValidationErrorsContainer,
      # ValidationError,

      # Api::V1::CalendarsController,
      # Calendar,
      # ErrorModel,
      # TokensController,
      # ErrorsContainer,
      # Error,
      self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end