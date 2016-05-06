class Api::V1::UsersController < ApiController
  before_filter :find_entity, only: [:show, :add_to_group, :remove_from_group]
  before_filter only: [:group_index, :add_to_group, :remove_from_group] do
    find_entity type: :group, id_param: :group_id
  end

  def me
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
