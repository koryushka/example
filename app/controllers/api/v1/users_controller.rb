class Api::V1::UsersController < ApiController
  #before_filter :authenticate_api_v1_user!, only: [:show, :me]

  def me
    @user = tmp_user
    render json: {user: 'me'}
  end

  def show
    @user = User.find_by_id(params[:id])

    if @user.nil?
      render json: {errors: [{message: "User not found #{params[:id]}", code: 404}]}, :status => :not_found
    end
  end

  def check_email
    user = User.find_by_email(params[:email])
    render json: !user.nil?
  end
end
