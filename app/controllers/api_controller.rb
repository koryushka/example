class ApiController < ActionController::Base
  include Doorkeeper::Helpers::Controller
  before_action :doorkeeper_authorize!

  rescue_from CanCan::AccessDenied do
    render json: {
        code: 1,
        message: 'You are not permited for this resourse'
    }, status: :forbidden
  end

  rescue_from ValidationException do |e|
    render json: { validation_errors: e.model.errors.messages }, status: :bad_request
  end

  rescue_from ActiveRecord::RecordNotUnique do |e|
    render json: {
        code: 1,
        message: "Duplication for #{controller_name.classify} entity",
        error_data: e.message[/DETAIL:.+/]
    }, status: :not_acceptable
  end

private

  def current_user
    @current_user ||= server.resource_owner
  end

  def pubnub
    if @pubnub.nil?
      logger = Logger.new(STDOUT)
      logger = Logger.new('/dev/null') if Rails.env.test?
      @pubnub = Pubnub.new(
          subscribe_key: 'sub-c-b30e1dac-d56c-11e5-b684-02ee2ddab7fe',
          publish_key: 'pub-c-dc0c88cf-f1dd-468d-88a4-160c26eb981d',
          logger: logger
      )

    end
    @pubnub
  end

  def publish(message)
    pubnub.publish(
        channel: "curago_dev_#{current_user.id}",
        message: message
    ) do |envelope|
      #puts envelope.parsed_response
    end
  end

  def something_updated
    publish('updated')
  end

  # Tries to find entity related to controller and adds appropriate class variable to controller
  #
  # +Params+:
  # *type*:
  #     type of model (:user, :admin, :document, etc.), should a symbol.
  #     if not specified method tries to find model corresponding to controller
  # *id_param*:
  #     name of request param which is being used as entite's identifer. should be a symbol. default: :id
  # *property_name*:
  #     name of class variable which will be added to controller and can be used by controller's methods.
  #     if not specified: method infers variable name from model's name for ex: CalendarItem is model name,
  #     so @calendar_item is class variable name
  # *condition*:
  #     helps to add filters during entity search. it's the same as codition for where() method
  def find_entity(type: nil, id_param: 'id'.to_sym, property_name: nil, condition: nil)
    # trying to find model name (if it is not specified) by controller name
    entity_class_name = (type.nil? ? controller_name : type.to_s).classify
    entity_class = entity_class_name.constantize
    relation = condition.nil? ? entity_class : entity_class.where(condition)

    # loading entity
    entity_id = params[id_param]
    entity = relation.where(id: entity_id).first

    if entity.nil?
      render text: "Could not find #{entity_class} with following id: '#{entity_id}'", status: :not_found
      return
    end

    # assigning controller's class property
    property_name = entity_class_name.underscore unless property_name
    class_eval { attr_accessor property_name }
    instance_variable_set "@#{property_name}", entity
  end

  # Tries to find entity related to controller and adds appropriate class variable to controller
  # The main condition: current user should own the entity which should be found
  #
  # +Params+:
  # *type*:
  #     type of model (:user, :admin, :document, etc.), should a symbol.
  #     if not specified method tries to find model corresponding to controller
  # *id_param*:
  #     name of request param which is being used as entite's identifer. should be a symbol. default: :id
  # *property_name*:
  #     name of class variable which will be added to controller and can be used by controller's methods.
  #     if not specified: method infers variable name from model's name for ex: CalendarItem is model name,
  #     so @calendar_item is class variable name
  def find_entity_of_current_user(type: nil, id_param: 'id'.to_sym, property_name: nil)
    find_entity(type: type, id_param: id_param, property_name: property_name, condition: {user_id: current_user.id})
  end

  def account_info_uri
    'https://www.googleapis.com/oauth2/v1/userinfo?access_token='
  end

  def refresh_token(google_access_token)
    uri = google_token_uri
    data = {
      grant_type: 'refresh_token',
      refresh_token: google_access_token.refresh_token,
      client_id: Rails.application.secrets.google_client_id,
      client_secret: Rails.application.secrets.google_client_secret,
    }
    request = Net::HTTP.post_form(URI.parse(uri), data)
    body = JSON.parse(request.body)
    google_access_token.update_attributes(
      token: body['access_token'],
      expires_at: Time.now + body['expires_in'].to_i
    )
  end

  def authorize(google_access_token)
    @google_oauth ||= Api::V1::GoogleOauthController.new
    @google_oauth.send :refresh_token, google_access_token if google_access_token.expired?
    @client = Signet::OAuth2::Client.new(access_token: google_access_token.token)
    @service ||= Google::Apis::CalendarV3::CalendarService.new
    @service.authorization = @client
  end
end
