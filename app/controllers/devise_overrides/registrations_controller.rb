class DeviseOverrides::RegistrationsController < DeviseTokenAuth::RegistrationsController
  include Doorkeeper::Helpers::Controller

  after_action :accept_family_invitation, only: [:create]

  rescue_from ValidationException do |e|
    render json: {
        code: 1,
        messages: t('errors.messages.validation_error'),
        validation_errors: e.model.errors.messages
    }, status: :bad_request
  end

protected
  def accept_family_invitation
    user = @resource
    participation = Participation.where(email: user.email,
                                        participationable_type: Group.name,
                                        status: Participation::PENDING).first
    return if participation.nil?

    participation.change_status_to(Participation::ACCEPTED)
  end

  # overriding of DeviseTokenAuth::Concerns::SetUserByToken
  def set_user_by_token(mapping=nil)
    # determine target authentication class
    rc = resource_class(mapping)

    # no default user defined
    return unless rc
    @resource = server.resource_owner

    # user has already been found and authenticated
    @resource if @resource and @resource.class == rc
  end

  def render_create_success
    render json: @resource.as_json
  end

  def render_create_error
    render json: {
        validation_errors: @resource.errors.messages
    }, status: :bad_request
  end

  def render_create_error_email_already_exists
    render json: {
        errors: [{code: 1, message: I18n.t('devise_token_auth.registrations.email_already_exists', email: @resource.email)}]
    }, status: :bad_request
  end

  def render_update_success
    render json: @resource.as_json
  end

  def render_update_error
    render json: {
        validation_errors: @resource.errors.messages
    }, status: :bad_request
  end

  def render_update_error_user_not_found
    render json: {
        errors: [{code: 1, message: I18n.t('devise_token_auth.registrations.user_not_found')}]
    }, status: :not_found
  end

  def render_destroy_success
    render json: {
        message: I18n.t('devise_token_auth.registrations.account_with_uid_destroyed', uid: @resource.uid)
    }, status: :no_content
  end

  def render_destroy_error
    render json: {
        errors: [{code: 1, message: I18n.t('devise_token_auth.registrations.account_to_destroy_not_found')}]
    }, status: :not_found
  end

private
  def validate_post_data(which, message)
    render json: {
        errors: [{code: 1, message: message}]
    }, status: :unprocessable_entity if which.empty?
  end
end