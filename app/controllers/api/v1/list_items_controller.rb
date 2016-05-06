class Api::V1::ListItemsController < ApiController
  before_filter :find_entity, except: [:index, :create]
  before_filter do
    find_entity_of_current_user type: :list, id_param: :list_id
  end
  before_filter only: [:assign, :unassign] do
    find_entity type: :user
  end
  after_filter :something_updated, except: [:index, :show]
  authorize_resource
  check_authorization

  def index
    @list_items = @list.list_items
  end

  def show
    render partial: 'list_item', locals: { list_item: @list_item }
  end

  def create
    @list_item = ListItem.new(list_item_params)
    @list_item.list = @list
    @list_item.user = current_user

    raise InternalServerErrorException unless @list_item.save
    render partial: 'list_item', locals: { list_item: @list_item }, status: :created
  end

  def update
    @list_item.assign_attributes(list_item_params)

    raise InternalServerErrorException unless @list_item.save
    render partial: 'list_item', locals: { list_item: @list_item }
  end

  def destroy
    @list_item.destroy
    render nothing: true, status: :no_content
  end

  def assign

  end

  def unassign

  end

private
  def list_item_params
    params.permit(:title, :notes, :done, :order)
  end
end