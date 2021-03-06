class Api::V1::EventsController < ApiController
  include Swagger::Blocks

  before_filter :find_entity, except: [:index, :create, :index_of_calendar]
  before_filter :find_entity, except: [:index, :create, :index_of_calendar, :index_of_list]
  before_filter only: [:add_to_calendar, :remove_from_calendar, :index_of_calendar] do
    find_entity_of_current_user type: :calendar, id_param: :calendar_id
  end
  before_filter only: [:add_list, :remove_list] do
    find_entity_of_current_user type: :list, id_param: :list_id
    authorize! :attach_private_list, @list
  end
  before_filter only: [:index_of_list] do
    find_entity_of_current_user type: :list, id_param: :list_id
  end
  authorize_resource
  check_authorization

  swagger_path '/events' do
    operation :get do
      key :summary, 'Current user calendar items'
      key :description, 'Returns all calendar items created by current user or shared with him'
      parameter do
        key :name, 'range_start'
        key :description, 'Begining date for events range. Default value is the begining of current month'
        key :in, 'query'
        key :required, false
        key :type, :string
        key :format, 'date-time'
      end
      parameter do
        key :name, 'range_end'
        key :description, 'End date for events range. Default value is the end of current month'
        key :in, 'query'
        key :required, false
        key :type, :string
        key :format, 'date-time'
      end
      parameter do
        key :name, 'time_zone'
        key :in, 'query'
        key :required, false
        key :type, :string
        key :default, 'UTC'
      end
      parameter do
        key :name, 'filter'
        key :description, 'Specifies which filter should be applied. Possible values: me, family, &lt;user_id> (identifier of family member)'
        key :in, 'query'
        key :required, false
        key :type, :string
      end
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', :ArrayOfEvents
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['Events']
    end # end operation :get
    # end operation :post
  end
  def index
    # TODO: must avoid N+1 query
    @events = current_user.all_events(query_params.fetch(:range_start, Date.today.beginning_of_month),
                                      query_params.fetch(:range_end, Date.today.end_of_month),
                                      query_params.fetch(:time_zone, 'UTC'),
                                      query_params.fetch(:filter, nil))
  end

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
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['Events']
    end
  end

  def show
    render partial: 'event', locals: {event: @event}
  end

  swagger_path '/events' do
    operation :post do
      key :summary, 'Create calendar item'
      key :description, 'Creates new calendar item.

Examples:

**E.B. choir practice weekdays at 5:30pm:**

*Event object properties:*

- **title**: E.B. choir practice
- **starts_at:** 5:30pm with date
- **event_recurrences_attributes**: array of EventReccurenceInput objects
  with following day property values: 1, 2, 3, 4, 5'
      parameter do
        key :name, 'event'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', :EventInput
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
          key :'$ref', :ValidationErrorsContainer
        end
      end # end response 400
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['Events']
    end
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user

    raise InternalServerErrorException unless @event.save

    MutedEvent.create(user_id: current_user.id, event_id: @event.id, muted: params[:muted]) if params[:muted].present?
    render partial: 'event', locals: {event: @event}, status: :created
  end

  swagger_path '/events/{id}' do
    operation :put do
      key :summary, 'Updates event'
      parameter do
        key :name, 'id'
        key :description, "Event's ID"
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, 'event'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', :EventInput
        end
      end
      response 201 do
        key :description, 'Updated'
        schema do
          key :'$ref', '#/definitions/Event'
        end
      end
      response 400 do
        key :description, 'Validation errors'
        schema do
          key :'$ref', :ValidationErrorsContainer
        end
      end
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['Events']
    end
  end

  def update
    @event.assign_attributes(event_params)
    authorize! :event_status_update, @event if @event.changes['public'].present?
    if @event.update(event_params)
      @event.update_google_event(current_user.id) if @event.etag
    end
    MutedEvent.create(user_id: current_user.id, event_id: @event.id, muted: params[:muted]) if params[:muted].present?
    render partial: 'event', locals: {event: @event}
  end

  swagger_path '/events/{id}' do
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
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['Events']
    end
  end

  def destroy
    if @event.destroy && @event.google_event_id
      @event.destroy_from_google
    end
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
    @events = @calendar.events.with_muted(current_user.id)
    @events = @events.where('events.updated_at > ?', query_params[:since]) if query_params[:since].present?
    #@shared_events = query_params[:since].nil? ? @calendar.shared_events : @calendar.shared_events.where('events.updated_at > ?', query_params[:since])
    @shared_events = []
  end

  def add_list
    @event.list = @list
    @event.save
    render nothing: true
  end

  def remove_list
    @event.list = nil
    @event.save
    render nothing: true, status: :no_content
  end

  def index_of_list
    @events = @list.events.with_muted(current_user.id)
    render 'index'
  end

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
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['Notifications', 'Events']
    end # end operation :post
  end

  def mute
    me = @event.muted_events.where(muted_events: {user_id: current_user.id}).first
    if me.present? && !me.muted?
      me.muted = true
      me.save
    else
      MutedEvent.create(event: @event, user: current_user, muted: true)
    end

    render nothing: true
  end

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
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['Notifications', 'Events']
    end # end operation :delete
  end

  def unmute
    me = @event.muted_events.where(muted_events: {user_id: current_user.id}).first
    if me.present? && me.muted?
      me.muted = false
      me.save
    end

    render nothing: true
  end

  private
  def event_params
    params.permit(:title, :starts_at, :ends_at, :all_day, :notes,
                  :kind, :latitude, :longitude, :location_name, :separation,
                  :count, :until, :frequency, :image_url, :public,
                  event_recurrences_attributes: [:day, :week, :month],
                  event_cancelations_attributes: [:date])
  end

  def query_params
    params.permit(:since, :range_start, :range_end, :time_zone, :filter)
  end

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
          key :'$ref', :EventCancellationInput
        end
      end
      # responses
      response 201 do
        key :description, 'Created'
        schema do
          key :'$ref', :EventCancellation
        end
      end # end response 201
      response 400 do
        key :description, 'Validation errors'
        schema do
          key :'$ref', :ValidationErrorsContainer
        end
      end # end response 400
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['Events', 'Event Cancellations']
    end # end operation :post
  end

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
          key :'$ref', :NotificationPreference
        end
      end # end response 200
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['Notifications', 'Events']
    end # end operation :get
    # end operation :post
  end

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
          key :'$ref', :ErrorsContainer
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
          key :'$ref', :Error
        end
      end # end response :default
      key :tags, ['Events']
    end # end operation :delete
  end
end
