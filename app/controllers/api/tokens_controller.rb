class Api::TokensController < Doorkeeper::TokensController
  include ActionController::StrongParameters

  def create
    @login_data = LoginData.new(auth_params)
    unless @login_data.valid?
      return render json: { validation_errors: @login_data.errors.messages }, status: :bad_request
    end

    super

    server.resource_owner.clean_tokens if server.resource_owner # resource owner is an instance of User model
  end

private

  def auth_params
    params.permit(:username, :password, :refresh_token, :scope, :grant_type)
  end
end
