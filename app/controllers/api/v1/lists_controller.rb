class Api::V1::ListsController < ApiController
  before_filter :find_entity, except: [:index, :create]
  after_filter :something_updated, except: [:index, :show]
  authorize_resource
  check_authorization

  def index
    @lists = current_user.lists
  end

  def show
    render partial: 'list', locals: { list: @list }
  end

  def create
    @list = List.new(list_params)
    @list.user = current_user
    if @list.valid?
      unless @list.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @list.errors.messages }, status: :bad_request
    end

    render partial: 'list', locals: { list: @list }, status: :created
  end

  def update
    @list.assign_attributes(list_params)

    if @list.valid?
      unless @list.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @list.errors.messages }, status: :bad_request
    end

    render partial: 'list', locals: { list: @list }
  end

  def destroy
    @list.destroy
    render nothing: true, status: :no_content
  end

private
  def list_params
    params.permit(:title, :notes, :kind)
  end
end