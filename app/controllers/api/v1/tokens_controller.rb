class Api::V1::TokensController < Doorkeeper::TokensController
  include ActionController::StrongParameters

  def create
    @login_data = LoginData.new(auth_params)
    return render json: {
        code: 1,
        messages: I18n.t('errors.messages.validation_error'),
        validation_errors: @login_data.errors.messages
    }, status: :bad_request unless @login_data.valid?

    super

    server.resource_owner.clean_tokens if server.resource_owner # resource owner is an instance of User model
  end

private

  def auth_params
    params.permit(:username, :password, :refresh_token, :scope, :grant_type)
  end
end
