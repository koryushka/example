class Api::V1::UsersController < Api::ApiController
  before_filter :authenticate_api_v1_user!, only: [:show, :me]

  def me
    @user = current_user
    render json: {user: 'me'}
  end

  def show
    @user = User.find_by_id(params[:id])

    if @user.nil?
      render :json => {errors: [{message: 'User not found' + " #{params[:id]}", code: 404}]}, :status => :not_found
    end
  end

  def check_email
    user = User.find_by_email(params[:email])
    render :json => !user.nil?
  end

  private
  def user_params
    params.permit(:email,
                  :user_name,
                  :password,
                  :password_confirmation)
  end
end
