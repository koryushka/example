class EventCancellation < AbstractModel
  include Swagger::Blocks

  belongs_to :event

  validates 'date', date: true, presence: true

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER SCHEMA: Model Event Cancellation
  # ================================================================================

  #swagger_schema :EventCancellationInput
  swagger_schema :EventCancellationInput do
    key :type, :object
    key :description, 'Specifies a date when event shall not occur or be canceled'
    property :date do
      key :type, :string
      key :format, 'date-time'
      key :description, 'the date of the recurrence of an event which should be cancelled. If the
          event spans multiple days, this column should be set to the first date on
          which the recurrence to be cancelled falls'
    end
  end # end swagger_schema :EventCancellationInput

end
