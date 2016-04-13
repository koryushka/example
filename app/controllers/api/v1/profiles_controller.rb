class Api::V1::ProfilesController < ApiController
  before_filter only: [:show, :update] do
    @user = current_user
    find_entity type: :user, id_param: :user_id unless params[:user_id].blank?
    render text: "Could not find profile for user id: '#{@user.id}'", status: :not_found if @user.profile.nil?
    @profile = @user.profile
  end
  authorize_resource
  check_authorization

  def show
    render partial: 'profile', locals: {profile: @profile}
  end

  def create
    @profile = Profile.new(profile_params)
    @profile.user = current_user

    return render nothing: true, status: :internal_server_error unless @profile.save
    render partial: 'profile', locals: {profile: @profile}, status: :created
  end

  def update
    @profile.assign_attributes(profile_params)

    return render nothing: true, status: :internal_server_error unless @profile.save
    render partial: 'profile', locals: {profile: @profile}
  end

private
  def profile_params
    params.permit(:full_name, :image_url, :color)
  end
end
