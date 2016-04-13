class Api::V1::GroupsController < ApiController
  before_filter :find_entity, except: [:index, :create]
  authorize_resource
  check_authorization

  def index
    @groups = current_user.groups
  end

  def show
    render partial: 'group', locals: {group: @group }
  end

  def create
    @group = Group.new(group_params)
    @group.owner = current_user


    return render nothing: true, status: :internal_server_error unless @group.save
    render partial: 'group', locals: {group: @group }, status: :created
  end

  def update
    @group.assign_attributes(group_params)


    return render nothing: true, status: :internal_server_error unless @group.save
    render partial: 'group', locals: {group: @group }
  end

  def destroy
    @group.destroy
    render nothing: true, status: :no_content
  end

  private
  def group_params
    params.permit(:title)
  end
end
