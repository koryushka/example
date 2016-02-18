class Api::V1::ListItemsController < ApiController
  before_filter :find_list_item, except: [:index, :create]
  before_filter :find_list, only: [:index, :create]
  after_filter :something_updated, except: [:index, :show]

  def index
    @list_items = @list.items
  end

  def show
    render partial: 'list_item', locals: { list_item: @list_item }
  end

  def create
    @list_item = ListItem.new(list_item_params)
    @list_item.list = @list
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
    params.permit(:title, :notes)
  end

  def find_list_item
    list_item_id = params[:id]
    @list_item = List.find_by(id: list_item_id)

    if @list_item.nil?
      render nothing: true, status: :not_found
    end
  end

  def find_list
    list_id = params[:list_id]
    @list = List.find_by(id: list_id)

    if @list.nil?
      render nothing: 'List not found', status: :not_found
    end
  end
end