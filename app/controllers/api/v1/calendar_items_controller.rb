class Api::V1::CalendarItemsController < ApiController
  before_filter :authenticate_api_v1_user!

  def index
    @calendar_items = current_api_v1_user.calendar_items
  end
end