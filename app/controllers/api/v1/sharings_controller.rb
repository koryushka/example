class Api::V1::SharingsController < ApiController
  include Swagger::Blocks

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

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER PATH: Controller Sharings (& /participations)
  # ================================================================================

  # swagger_path /sharings
  swagger_path '/sharings' do
    operation :post do
      key :summary, 'Shares some entity with some user'
      parameter do
        key :name, 'sharing_data'
        key :required, true
        schema do
          key :'$ref', '#/definitions/SharingInput'
        end
      end
      # responses
      response 201 do
        key :description, 'Created'
        schema do
          key :'$ref', '#/definitions/SharingItem'
        end
      end # end response 201
      key :tags, ['Sharings']
    end # end operation :post
  end # end swagger_path /sharings

  # swagger_path /participations
  swagger_path '/participations' do
    operation :get do
      key :summary, 'Current user participations'
      key :description, 'Returns all shareable items (calendar group, calendar, calendar item, document or list)
shared BY current user'
      # responses
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', '#/definitions/ArrayOfParticipations'
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['Participations']
    end # end operation :get
    operation :post do
      key :summary, 'Create participation'
      key :description, 'Share some shareable item (calendar group, calendar, calendar item, document or list)
 with friend'
      # responses
      response 201 do
        key :description, 'Created'
        schema do
          key :'$ref', '#/definitions/Participation'
        end
      end # end response 201
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['Participations']
    end # end operation :post
  end # end swagger_path /participations

  # swagger_path /participations/:id
  swagger_path '/participations/:id' do
    operation :put do
      key :summary, 'Update participation'
      key :description, 'Updates participation information by ID'
      # responses
      response 201 do
        key :description, 'Updated'
        schema do
          key :'$ref', '#/definitions/Participation'
        end
      end # end response 201
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['Participations']
    end # end operation :put
    operation :delete do
      key :summary, 'Delete participation'
      key :description, 'Deletes participation by ID'
      # responses
      response 204 do
        key :description, 'Deleted'
      end # end response 204
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['Participations']
    end # end operation :delete
  end # end swagger_path /participations/:id

end