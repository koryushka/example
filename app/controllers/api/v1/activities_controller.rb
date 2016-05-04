class Api::V1::ActivitiesController < ApiController
  authorize_resource
  check_authorization

  def index
    @activities = current_user.activities
  end
end
