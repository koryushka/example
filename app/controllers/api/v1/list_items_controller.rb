class Api::V1::ListItemsController < ApiController
  before_filter :find_entity, except: [:index, :create]
  before_filter only: [:index, :create] do
    find_entity type: :list, id_param: :list_id
  end
  after_filter :something_updated, except: [:index, :show]
  authorize_resource
  check_authorization

  def index
    @list_items = @list.items
  end

  def show
    render partial: 'list_item', locals: { list_item: @list_item }
  end

  def create
    @list_item = ListItem.new(list_item_params)
    @list_item.list = @list
    @list_item.user = current_user
    if @list_item.valid?
      unless @list_item.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @list_item.errors.messages }, status: :bad_request
    end

    render partial: 'list_item', locals: { list_item: @list_item }, status: :created
  end

  def update
    @list_item.assign_attributes(list_item_params)

    if @list_item.valid?
      unless @list_item.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @list_item.errors.messages }, status: :bad_request
    end

    render partial: 'list_item', locals: { list_item: @list_item }
  end

  def destroy
    @list_item.destroy
    render nothing: true, status: :no_content
  end

private
  def list_item_params
    params.permit(:title, :notes, :done, :order)
  end
end