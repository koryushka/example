class EventRecurrence < ActiveRecord::Base
  include Swagger::Blocks

  belongs_to :event

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER SCHEMA: Model Event Reccurence
  # ================================================================================

  # swagger_schema :EventReccurenceInput
  swagger_schema :EventReccurenceInput do
    key :type, :object
    property :day do
      key :type, :integer
      key :description, 'For weekly recurring events:
  the day of the week the event occurs.
  0 = Sunday, 1 = Monday, ..., 6 = Saturday.
For monthly recurring events:
  if the week property is NULL, the day property specifies the day of the
  month that the event occurs. If the week property is non-NULL, the day
  property specifies the day of the week that the event occurs in that week
  of the month.'
    end
    property :week do
      key :type, :integer
      key :description, 'For weekly recurring events:
  these properties should be set to NULL for weekly recurring events.
  Setting these properties to non-NULL values will cause unspecified results.
For yearly recurring events:
  the usage for the week and day properties of a yearly recurring event are
  exactly the same as their usage for monthly recurring events.'
    end
    property :month do
      key :type, :integer
      key :description, 'For monthly recurring events:
  this property should be set to NULL for monthly recurring events.
  Setting this property to a non-NULL value will cause unspecified results.
For yearly recurring events:
  if the month property is non-NULL, it specifies the month for which this
  pattern should be used. If it is NULL, this pattern will be for the
  month of the original date/time of the event.'
    end
  end # end swagger_schema :EventReccurenceInput

end

