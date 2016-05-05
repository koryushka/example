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
      SwaggerSchema,
      TokensController,
      CalendarsGroupsController,
      CalendarsGroup,
      CalendarsController,
      Calendar,
      EventsController,
      Event,
      EventCancellationsController,
      EventCancellation,
      EventRecurrence,
      NotificationsPrefsController,
      NotificationsPreference,
      FilesController,
      UploadedFile,
      ListItemsController,
      ListItem,
      ListsController,
      List,
      SharingsController,
      UsersController,
      User,
      Profile,
      GroupsController,
      Group,
      self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end