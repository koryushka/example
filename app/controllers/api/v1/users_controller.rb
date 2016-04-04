class Api::V1::UsersController < ApiController
  before_filter :find_entity, only: [:show, :add_to_group, :remove_from_group]
  before_filter only: [:group_index, :add_to_group, :remove_from_group] do
    find_entity type: :group, id_param: :group_id
  end

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

  # Group members
  def group_index
    @members = @group.members
  end

  def add_to_group
    @group.members << @user
    render nothing: true
  end

  def remove_from_group
    @group.members.delete(@user)
    render nothing: true, status: :no_content
  end
end
