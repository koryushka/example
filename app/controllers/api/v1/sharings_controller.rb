class Api::V1::SharingsController < ApiController
  before_filter only:[:destroy] do
    find_entity :sharing_permision
  end

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

  def destroy
    @sharing_permission.destroy
    render nothing: true, status: :no_content
  end

  def resources
    result = []
    hidden_actions = []
    Rails.application.eager_load!
    ApiController.descendants.each do |controller|
      actions = []
      (controller.action_methods.to_a - hidden_actions).each do |action|
        actions << action
      end
      result << {
        name: controller.controller_name.classify,
        actions: actions
      }
    end

    render json: result
  end

private
  def sharing_params
    params.permit(:subject_class, :subject_id, :user_id, :action)
  end
end