class Api::V1::EventsController < ApiController
  include Swagger::Blocks

  before_filter :find_entity, except: [:index, :create, :index_of_calendar]
  before_filter only: [:add_to_calendar, :remove_from_calendar, :index_of_calendar] do
    find_entity_of_current_user type: :calendar, id_param: :calendar_id
  end
  after_filter :something_updated, except: [:index, :show, :index_of_calendar]
  authorize_resource
  check_authorization

  def index
    @events = current_user.events.includes(:event_cancellations, :event_recurrences)
  end

  def show
    render partial: 'event', locals: {event: @event }
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user

    unless @event.save
      return render nothing: true, status: :internal_server_error
    end

    render partial: 'event', locals: {event: @event }, status: :created
  end

  def update
    @event.assign_attributes(event_params)

    unless @event.save
      return render nothing: true, status: :internal_server_error
    end

    render partial: 'event', locals: {event: @event }
  end

  def destroy
    @event.destroy
    render nothing: true, status: :no_content
  end

  def add_to_calendar
    @calendar.events << @event
    render nothing: true
  end

  def remove_from_calendar
    @calendar.events.delete(@event)
    render nothing: true, status: :no_content
  end

  def index_of_calendar
    @events = query_params[:since].nil? ? @calendar.events : @calendar.events.where('events.updated_at > ?', query_params[:since])
    #@shared_events = query_params[:since].nil? ? @calendar.shared_events : @calendar.shared_events.where('events.updated_at > ?', query_params[:since])
    @shared_events = []
  end

private
  def event_params
    params.permit(:title, :starts_at, :ends_at, :all_day, :notes,
                  :kind, :latitude, :longitude, :location_name, :separation,
                  :count, :until, :timezone_name, :frequency,
                  event_recurrences_attributes: [:day, :week, :month],
                  event_cancelations_attributes: [:date])
  end

  def query_params
    params.permit(:since)
  end

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER PATH: Controller Event
  # ================================================================================

  # swagger_path /events
  swagger_path '/events' do
    operation :get do
      key :summary, 'Current user calendar items'
      key :description, 'Returns all calendar items created by current user or shared with him'
      # responses
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', '#/definitions/ArrayOfEvents'
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response :default
      key :tags, ['Events']
    end # end operation :get
    operation :post do
      key :summary, 'Create calendar item'
      key :description, "Creates new calendar item.

Examples:

**E.B. choir practice weekdays at 5:30pm:**

*Event object properties:*

- **title**: E.B. choir practice
- **starts_at:** 5:30pm with date
- **event_recurrences_attributes**: array of EventReccurenceInput objects
  with following day property values: 1, 2, 3, 4, 5"
      parameter do
        key :name, 'event'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', '#/definitions/EventInput'
        end
      end
      # responses
      response 201 do
        key :description, 'Created'
        schema do
          key :'$ref', '#/definitions/Event'
        end
      end # end response 201
      response 400 do
        key :description, 'Validation errors'
        schema do
          key :'$ref', '#/definitions/ValidationErrorsContainer'
        end
      end # end response 400
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response :default
      key :tags, ['Events']
    end # end operation :post
  end # end swagger_path /events

  # swagger_path /events/{id}
  swagger_path '/events/{id}' do
    operation :get do
      key :summary, 'Returns event'
      parameter do
        key :name, 'id'
        key :description, "Calendar's ID"
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      # responses
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', '#/definitions/Event'
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response :default
      key :tags, ['Events']
    end # end operation :get
    operation :put do
      key :summary, 'Updates event'
      parameter do
        key :name, 'id'
        key :description, "Calendar's ID"
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, 'id'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', '#/definitions/EventInput'
        end
      end
      # responses
      response 201 do
        key :description, 'Updated'
        schema do
          key :'$ref', '#/definitions/Event'
        end
      end # end response 201
      response 400 do
        key :description, 'Validation errors'
        schema do
          key :'$ref', '#/definitions/ValidationErrorsContainer'
        end
      end # end response 400
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response :default
      key :tags, ['Events']
    end # end operation :put
    operation :delete do
      key :summary, 'Deletes event'
      parameter do
        key :name, 'id'
        key :description, "Calendar's ID"
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
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response :default
      key :tags, ['Events']
    end # end operation :delete
  end # end swagger_path /events/{id}

  # swagger_path /events/{id}/cancellations
  swagger_path '/events/{id}/cancellations' do
    operation :post do
      key :summary, 'Cancels event for a specific date'
      parameter do
        key :name, 'id'
        key :description, 'Event ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, 'id'
        key :description, 'Cancellation data'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', '#/definitions/EventCancellationInput'
        end
      end
      # responses
      response 201 do
        key :description, 'Created'
        schema do
          key :'$ref', '#/definitions/EventCancellation'
        end
      end # end response 201
      response 400 do
        key :description, 'Validation errors'
        schema do
          key :'$ref', '#/definitions/ValidationErrorsContainer'
        end
      end # end response 400
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response :default
      key :tags, ['Events', 'Event Cancellations']
    end # end operation :post
  end # end swagger_path /events/{id}/cancellations

  # swagger_path /events/{event_id}/lists/{list_id}
  swagger_path '/events/{event_id}/lists/{list_id}' do
    operation :post do
      key :summary, 'Assigns specified list to specified event'
      parameter do
        key :name, 'event_id'
        key :description, 'Event ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, 'list_id'
        key :description, 'ID of list which should be added'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      # responses
      response 200 do
        key :description, 'OK'
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/ErrorsContainer'
        end
      end # end response :default
      key :tags, ['Events']
    end # end operation :post
    operation :delete do
      key :summary, 'Removes specified list from specified event'
      parameter do
        key :name, 'event_id'
        key :description, 'Event ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, 'list_id'
        key :description, 'ID of list which should be removed'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      response 204 do
        key :description, 'Deleted'
      end # end response 204
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/Error'
        end
      end # end response :default
      key :tags, ['Events']
    end # end operation :delete
  end # end swagger_path /events/{event_id}/lists/{list_id}

  # swagger_path /events/{id}/notifications
  swagger_path '/events/{id}/notifications' do
    operation :get do
      key :summary, 'Returns notifications preferences for calendar item'
      parameter do
        key :name, 'id'
        key :description, 'Event ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      # responses
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', '#/definitions/NotificationPreference'
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/Error'
        end
      end # end response :default
      key :tags, ['Notifications', 'Events']
    end # end operation :get
    operation :post do
      key :summary, 'Create notification preference'
      key :description, 'Creates new notification preference'
      parameter do
        key :name, 'id'
        key :description, 'Event ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      # responses
      response 201 do
        key :description, 'Created'
        schema do
          key :'$ref', '#/definitions/NotificationPreference'
        end
      end # end response 201
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/Error'
        end
      end # end response :default
      key :tags, ['Notifications', 'Events']
    end # end operation :post
  end # end swagger_path /events/{id}/notifications

  # swagger_path /events/{id}/mute
  swagger_path '/events/{id}/mute' do
    operation :post do
      key :summary, 'Stops sending notifications for specified event'
      parameter do
        key :name, 'id'
        key :description, 'Event ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      # responses
      response 200 do
        key :description, 'OK'
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/Error'
        end
      end # end response :default
      key :tags, ['Notifications', 'Events']
    end # end operation :post
  end # end swagger_path /events/{id}/mute

  # swagger_path /events/{id}/unmute
  swagger_path '/events/{id}/unmute' do
    operation :delete do
      key :summary, 'Re-starts sending notifications for specified event'
      parameter do
        key :name, 'id'
        key :description, 'Event ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      # responses
      response 200 do
        key :description, 'OK'
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', '#/definitions/Error'
        end
      end # end response :default
      key :tags, ['Notifications', 'Events']
    end # end operation :delete
  end # end swagger_path /events/{id}/unmute
end


