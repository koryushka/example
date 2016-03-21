class Api::V1::CalendarsGroupsController < ApiController
  before_filter :find_entity, except: [:index, :create]
  authorize_resource
  check_authorization
  after_filter :something_updated, except: [:index, :show]

  def index
    @groups = current_user.calendars_groups
  end

  def show
    render partial: 'group', locals: { group: @calendars_group }
  end

  def create
    @calendars_group = CalendarsGroup.new(calendars_group_params)
    @calendars_group.user = current_user
    if @calendars_group.valid?
      unless @calendars_group.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @calendars_group.errors.messages }, status: :bad_request
    end

    render partial: 'group', locals: { group: @calendars_group }, status: :created
  end

  def update
    @calendars_group.assign_attributes(calendars_group_params)

    if @calendars_group.valid?
      unless @calendars_group.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @calendars_group.errors.messages }, status: :bad_request
    end

    render partial: 'group', locals: { group: @calendars_group }, status: :created
  end

  def destroy
    @calendars_group.destroy
    render nothing: true, status: :no_content
  end

private
  def calendars_group_params
    params.permit(:title)
  end
end