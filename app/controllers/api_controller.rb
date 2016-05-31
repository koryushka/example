class ApiController < ActionController::Base
  include Doorkeeper::Helpers::Controller

  before_action do
    doorkeeper_authorize! unless should_pass?
  end

  rescue_from CanCan::AccessDenied do
    render json: {
        code: 2,
        message: t('errors.messages.not_permitted')
    }, status: :forbidden
  end

  rescue_from ActiveRecord::RecordNotUnique do |e|
    render json: {
        code: 3,
        message: t('errors.messages.entity_duplication', entity_name: controller_name.classify),
        error_data: e.message[/DETAIL:.+/]
    }, status: :not_acceptable
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: {
        code: 4,
        message: e.message,
        error_data: nil
    }, status: :not_found
  end

  rescue_from AppException do |e|
    render json: {
        code: e.code,
        message: e.message,
        error_data: e.data
    }, status: e.http_status
  end
private
  def should_pass?
    self.respond_to?(:unauth_actions) && self.unauth_actions.include?(action_name.to_sym)
  end

  def current_user
    @current_user ||= server.resource_owner
  end

  def something_updated
    PubnubHelpers::Publisher.publish('updated', current_user.id)
  end

  # Tries to find entity of specified type using condition
  # *type*:
  #     type of model (:user, :admin, :document, etc.), should a symbol.
  # *condition*:
  #     helps to add filters during entity search. it's the same as codition for where() method
  def find_entity_of_type(type, condition)
    entity_class = type.to_s.classify.constantize
    entity = entity_class.where(condition).first
    raise NotFoundException if entity.nil?

    property_name = entity_class.name.underscore
    class_eval { attr_accessor property_name }
    instance_variable_set "@#{property_name}", entity
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

    raise NotFoundException if entity.nil?

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
end
