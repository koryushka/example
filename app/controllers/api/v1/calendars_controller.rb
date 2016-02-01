class Api::V1::CalendarsController < ApiController
  before_filter :authenticate_api_v1_user!

  def index
    @calendars = current_api_v1_user.calendars
  end
end