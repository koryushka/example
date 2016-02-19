class ApiController < ActionController::Base
  #include DeviseTokenAuth::Concerns::SetUserByToken
  #before_filter :authenticate_api_user!

  rescue_from CanCan::AccessDenied do
    render :text => '401. Unauthorized. You are not permited for this resourse.', :status => :unauthorized
  end

private

  def current_user
    send "current_#{controller_scope}_user"
  end

  def pubnub
    @pubnub ||= Pubnub.new(
        subscribe_key: 'sub-c-b30e1dac-d56c-11e5-b684-02ee2ddab7fe',
        publish_key: 'pub-c-dc0c88cf-f1dd-468d-88a4-160c26eb981d'
    )
  end

  def publish(message)
    pubnub.publish(
        channel: "curago_dev_#{tmp_user.id}",
        message: message
    ) do |envelope|
      puts envelope.parsed_response
    end
  end

  def something_updated
    publish('updated')
  end

  def tmp_user
    @tmp_user ||= User.find(5)
  end

  def controller_scope
    self.class.name.parent_name.split('::').join('_').downcase
  end

  def authenticate_api_user!
    send "authenticate_#{controller_scope}_user!"
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
  def find_entity(type: nil, id_param: 'id'.to_sym, property_name: nil)
    # trying to find model name (if it is not specified) by controller name
    entity_class_name = (type.nil? ? controller_name : type.to_s).classify
    entity_class = entity_class_name.constantize

    # loading entity
    entity_id = params[id_param]
    entity = entity_class.find_by(id: entity_id)

    if entity.nil?
      render text: "Could not find #{entity_class} with following id: '#{entity_id}'", status: :not_found
      return
    end

    # assigning controller's class property
    property_name = entity_class_name.underscore unless property_name
    class_eval { attr_accessor property_name }
    instance_variable_set "@#{property_name}", entity
  end
end
