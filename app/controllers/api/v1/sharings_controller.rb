class Api::V1::SharingsController < ApiController
  def create
    @sharing_permission = SharingPermission.new(sharing_params)
    if @sharing_permission.valid?
      unless @sharing_permission.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @sharing_permission.errors.messages }, status: :bad_request
    end

    render partial: 'sharing_permission', locals: { sharing_permission: @sharing_permission }, status: :created
  end

private
  def sharing_params
    params.permit(:subject_class, :subject_id, :user_id, :action)
  end
end