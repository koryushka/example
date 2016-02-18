class Api::V1::NotificationsPrefsController < ApiController
  before_filter :find_calendar_item
  before_filter :find_prefs, except: [:create, :index]
  after_filter :something_updated, except: [:index]

  def index
    @prefs = @calendar_item.notifications_preference
    render partial: 'prefs', locals: {prefs: @prefs }, status: :created
  end

  def create
    @prefs = NotificationsPreference.new(pref_params)
    if @prefs.valid?
      @calendar_item.notifications_preference = @prefs
      unless @calendar_item.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @prefs.errors.messages }, status: :bad_request
    end

    render partial: 'prefs', locals: {prefs: @prefs }, status: :created
  end

  def update
    @prefs.assign_attributes(pref_params)

    if @prefs.valid?
      unless @prefs.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @prefs.errors.messages }, status: :bad_request
    end

    render partial: 'prefs', locals: {prefs: @prefs }, status: :created
  end

  def destroy
    @prefs.destroy
    render nothing: true, status: :no_content
  end

private
  def pref_params
    params.permit(:email, :sms, :push)
  end

  def find_prefs
    prefs_id = params[:id]
    @prefs = NotificationsPreference.find_by(id: prefs_id)

    if @prefs.nil?
      render nothing: true, status: :not_found
    end
  end

  def find_calendar_item
    calendar_item_id = params[:calendar_item_id]
    @calendar_item = CalendarItem.find_by(id: calendar_item_id)

    if @calendar_item.nil?
      render nothing: true, status: :not_found
    end
  end
end