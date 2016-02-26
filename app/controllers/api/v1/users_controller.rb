class Api::V1::UsersController < ApiController
  #before_filter :authenticate_api_v1_user!, only: [:show, :me]

  def me
    render partial: 'user', locals: { user: current_user }, status: :created
  end

  def show
    @user = User.find_by_id(params[:id])

    if @user.nil?
      render json: {errors: [{message: "User not found #{params[:id]}", code: 404}]}, :status => :not_found
    end
  end

  def update
    current_user.assign_attributes(user_params)
    if current_user.valid?
      unless current_user.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: current_user.errors.messages }, status: :bad_request
    end

    render partial: 'user', locals: { user: current_user }, status: :created
  end

  def check_email
    user = User.find_by_email(params[:email])
    render json: !user.nil?
  end

  private
  def user_params
    params.permit(:user_name, :email)
  end
end
