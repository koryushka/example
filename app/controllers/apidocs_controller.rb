class ApidocsController < ActionController::Base
  include Swagger::Blocks
  # include Api

  swagger_root do
    key :swagger, '2.0'
    info do
      key :version, '1.3.0'
      key :title, 'Curago API'
      key :description, 'API documentation for Curago'
    end

    key :schemes, 'http'
    key :basePath, '/api/v1'
    key :produces, ['application/json']
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
      Api::V1::CalendarsController,
      self,
  ].freeze

  def index
    puts "sdfsdf"
    render nothing: true
    #render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
    swagger_data = Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
    File.open('swagger.json', 'w') { |file| file.write(swagger_data.to_json) }
  end
end