class Api::V1::ProfilesController < ApiController
  before_filter only: [:show] do
    find_entity type: :user, id_param: :user_id
  end
  before_filter only: [:index, :update] do
    @profile = current_user.profile
  end
  authorize_resource
  check_authorization

  def show
    @profile = @user.profile
    render partial: 'profile', locals: {profile: @profile}
  end

  def create
    @profile = Profile.new(profile_params)
    @profile.user = current_user

    unless @profile.save
      return render nothing: true, status: :internal_server_error
    end

    render partial: 'profile', locals: {profile: @profile }, status: :created
  end

  def update
    @profile.assign_attributes(profile_params)

    unless @profile.save
      return render nothing: true, status: :internal_server_error
    end

    render partial: 'profile', locals: {profile: @profile }
  end

private
  def profile_params
    params.permit(:full_name, :image_url, :color)
  end
end
