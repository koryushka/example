class Api::V1::NotificationsPrefsController < ApiController
  include Swagger::Blocks

  before_filter :find_calendar_item
  before_filter :find_prefs, except: [:create, :index]
  after_filter :something_updated, except: [:index]
  #authorize_resource
  #check_authorization

  def index
    @prefs = @calendar_item.notifications_preference
    render partial: 'prefs', locals: {prefs: @prefs }, status: :created
  end

  def create
    @prefs = NotificationsPreference.new(pref_params)
    if @prefs.valid?
      @calendar_item.notifications_preference = @prefs
      unless @calendar_item.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @prefs.errors.messages }, status: :bad_request
    end

    render partial: 'prefs', locals: {prefs: @prefs }, status: :created
  end

  def update
    @prefs.assign_attributes(pref_params)

    if @prefs.valid?
      unless @prefs.save!
        return render nothing: true, status: :internal_server_error
      end
    else
      return render json: { validation_errors: @prefs.errors.messages }, status: :bad_request
    end

    render partial: 'prefs', locals: {prefs: @prefs }, status: :created
  end

  def destroy
    @prefs.destroy
    render nothing: true, status: :no_content
  end

private
  def pref_params
    params.permit(:email, :sms, :push)
  end

  def find_prefs
    prefs_id = params[:id]
    @prefs = NotificationsPreference.find_by(id: prefs_id)

    if @prefs.nil?
      render nothing: true, status: :not_found
    end
  end

  def find_calendar_item
    calendar_item_id = params[:calendar_item_id]
    @calendar_item = Event.find_by(id: calendar_item_id)

    if @calendar_item.nil?
      render nothing: true, status: :not_found
    end
  end

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER PATH: Controller Notifications Preferences
  # ================================================================================

  # swagger_path /notification_prefs/{id}
  swagger_path '/notification_prefs/{id}' do
    operation :put do
      key :summary, 'Update notification preference'
      key :description, 'Updates notification preference by ID'
      parameter do
        key :name, 'id'
        key :description, 'Notifications preference ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      # responses
      response 201 do
        key :description, 'Updated'
        schema do
          key :'$ref', '#/definitions/NotificationPreference'
        end
      end # end response 201
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['Notifications', 'Events']
    end # end operation :put
    operation :delete do
      key :summary, 'Delete notification preference'
      key :description, 'Deletes notification preference by ID'
      parameter do
        key :name, 'id'
        key :description, 'Notifications preference ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
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
      key :tags, ['Notifications', 'Events']
    end # end operation :delete
  end # end swagger_path '/notification_prefs/{id}'

end
