class Calendar < AbstractModel
  belongs_to :user
  has_and_belongs_to_many :events
  has_and_belongs_to_many :calendars_groups
  has_and_belongs_to_many :complex_events, join_table: 'calendars_events', readonly: true, association_foreign_key: 'event_id'

  validates :title, length: {maximum: 128}, presence: true
  validates :hex_color, length: {maximum: 6}
  validates :main, inclusion: {in: [true, false]}, allow_blank: true
  validates :kind, allow_blank: true, numericality: {only_integer: true}
  validates :visible, allow_blank: true, inclusion: {in: [true, false]}

  default :kind, 0
  default :visible, true
  default :main, false

  def shared_events
    if self.main?
      cic = Arel::Table.new(:calendars_events)
      sharings = SharingPermission.arel_table
      complex_events = ComplexEvent.arel_table
      # items shared through calendars
      shared_items_from_calendars = complex_events.join(cic).on(cic[:event_id].eq(complex_events[:id]))
                               .join(sharings).on(sharings[:subject_id].eq(cic[:calendar_id])
                                                      .and(sharings[:subject_class].eq(Calendar.name))
                                                      .and(sharings[:user_id].eq(self.user_id)))
                               .project(complex_events[Arel.star]).where(complex_events[:frequency].not_eq(nil))
      # items shared directly
      shared_items = complex_events.join(sharings).on(sharings[:subject_id].eq(complex_events[:id])
                                                 .and(sharings[:subject_class].eq(Event.name))
                                                 .and(sharings[:user_id].eq(self.user_id)))
                         .project(complex_events[Arel.star])
      return Event.find_by_sql(shared_items_from_calendars.union(shared_items).to_sql)
    end

    Event.where(id: nil)
  end

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER PATH: Model Calendar
  # ================================================================================
  include Swagger::Blocks

  # Definition calendar
  swagger_schema :Calendar do
    key :type, :object
    property :id do
      key :type, :integer
      key :description, 'Calendar ID'
    end
    property :title do
      key :type, :string
      key :description, 'Calendar title'
    end
    property :creator do
      key :type, :string
      key :description, 'User ID who created this calendar'
    end
    property :hex_color do
      key :type, :string
      key :description, 'Calendar color in hex string'
    end
    property :main do
      key :type, :boolean
      key :description, 'Specifies is it default Curago calendar for user or not'
      key :default, false
    end
    property :kind do
      key :type, :integer
      key :format, :int16
      key :description, 'Enumeration specifies the type of calendar'
      key :default, 0
    end
    property :visible do
      key :type, :boolean
      key :description, 'Specifies if calendar visible in UI'
      key :default, true
    end
  end # end definition Calendar

  # Definition ArrayOfCalendars
  swagger_schema :ArrayOfCalendars do
    key :type, :array
    items do
      key :'$ref', '#/definitions/Calendar'
    end
  end # end swagger_schema :ArrayOfCalendars
end
