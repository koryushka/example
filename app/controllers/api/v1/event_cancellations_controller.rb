class Api::V1::EventCancellationsController < ApiController
  include Swagger::Blocks

  before_filter only:[:create] do
    find_entity type: :event, id_param: :event_id
  end
  before_filter :find_entity, except: [:create]

  def create
    @event_cancellation = EventCancellation.new(event_cancellation_params)
    @event_cancellation.event = @event

    return render nothing: true, status: :internal_server_error unless @event_cancellation.save
    render partial: 'event_cancellation', locals: {event_cancellation: @event_cancellation }, status: :created
  end

  # swagger_path /event_cancellations/{id}
  swagger_path '/event_cancellations/{id}' do
    operation :put do
      key :summary, 'Updates event cancellation'
      parameter do
        key :name, 'id'
        key :description, 'Event ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, 'data'
        key :description, 'Cancellation data'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', :EventCancellationInput
        end
      end
      # responses
      response 200 do
        key :description, 'Updated'
        schema do
          key :'$ref', :EventCancellation
        end
      end # end response 200
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
    end # end operation :put
    operation :delete do
      key :summary, 'Removes event cancellation'
      parameter do
        key :name, 'id'
        key :description, 'Event ID'
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
      key :tags, ['Events', 'Event Cancellations']
    end # end operation :delete
  end # end swagger_path /event_cancellations/{id}
  def update
    @event_cancellation.assign_attributes(event_cancellation_params)

    return render nothing: true, status: :internal_server_error unless @event_cancellation.save
    render partial: 'event_cancellation', locals: {event_cancellation: @event_cancellation }
  end

  def destroy
    @event_cancellation.destroy
    render nothing: true, status: :no_content
  end

private
  def event_cancellation_params
    params.permit(:date)
  end

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER PATH: Controller Event Cancellation
  # ================================================================================



end