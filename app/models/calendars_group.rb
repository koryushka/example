class CalendarsGroup < AbstractModel
  include Swagger::Blocks

  belongs_to :user
  has_and_belongs_to_many :calendars

  validates :title, length: {maximum: 128}, presence: true

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER SCHEMA: Model Calendars Group
  # ================================================================================

  # Definition CalendarsGroup
  swagger_schema :CalendarsGroup do
    key :type, :object
    property :id do
      key :type, :integer
      key :description, 'Calendar group ID'
    end
    property :title do
      key :type, :string
      key :description, 'Calendar group title'
    end
  end # end swagger_schema :CalendarsGroup

  # Definition ArrayOfCalendarGroups
  swagger_schema :ArrayOfCalendarGroups do
    key :type, :array
    items do
      key :'$ref', '#/definitions/CalendarsGroup'
    end
  end # end swagger_schema :ArrayOfCalendarGroups

  # Definition CalendarsGroupInput
  swagger_schema :CalendarsGroupInput do
    key :type, :object
    property :title do
      key :type, :string
      key :description, 'Calendar group title'
    end
  end # end swagger_schema :CalendarsGroupInput


end


