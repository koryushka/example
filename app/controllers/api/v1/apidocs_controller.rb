module Api
  module V1
    class Api::V1::ApidocsController < ActionController::Base
      include Swagger::Blocks

      swagger_root do
        key :swagger, '2.0'
        info do
          key :version, '1.4.0'
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
          AccountsController,
          GoogleOauthController,
          GoogleAccessToken,
          CalendarsController,
          Calendar,
          EventsController,
          Event,
          EventCancellationsController,
          EventCancellation,
          EventRecurrence,
          FilesController,
          UploadedFile,
          ListItemsController,
          ListItem,
          ListsController,
          List,
          UsersController,
          User,
          ProfilesController,
          Profile,
          GroupsController,
          Group,
          ParticipationsController,
          Participation,
          DevicesController,
          Device,
          self,
      ].freeze

      def index
        render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
      end
    end
  end
end
