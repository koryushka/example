class Api::V1::CalendarsGroupsController < ApiController
  before_filter :find_calendars_group, except: [:index, :create]
  authorize_resource
  check_authorization
  after_filter :something_updated, except: [:index, :show]

  def index
    @groups = tmp_user.calendars_groups
  end

  def show
    render partial: 'group', locals: { group: @group }
  end

  def create
    @group = CalendarsGroup.new(calendars_group_params)
    @group.user = tmp_user
    if @group.valid?
      unless @group.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @group.errors.messages }, status: :bad_request
    end

    render partial: 'group', locals: { group: @group }, status: :created
  end

  def update
    @group.assign_attributes(calendars_group_params)

    if @group.valid?
      unless @group.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @group.errors.messages }, status: :bad_request
    end

    render partial: 'group', locals: { group: @group }, status: :created
  end

  def destroy
    @group.destroy
    render nothing: true, status: :no_content
  end

private
  def calendars_group_params
    params.permit(:title)
  end

  def find_calendars_group
    calendars_group_id = params[:id]
    @group = CalendarsGroup.find_by(id: calendars_group_id)

    if @group.nil?
      render nothing: true, status: :not_found
    end
  end
end