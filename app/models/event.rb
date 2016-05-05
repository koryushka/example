class Event < AbstractModel
  include Swagger::Blocks

  belongs_to :user
  has_and_belongs_to_many :calendars
  has_and_belongs_to_many :documents
  has_one :notifications_preference
  has_many :complex_events, foreign_key: 'id'
  has_many :event_recurrences, dependent: :destroy
  has_many :event_cancellations, dependent: :destroy
  belongs_to :list
  has_many :muted_events

  scope :with_muted, -> (user_id){includes(:muted_events)
                                      .references(:muted_events)
                                      .where('"muted_events"."user_id" IS NULL OR "muted_events"."user_id" = :user_id', user_id: user_id)}

  accepts_nested_attributes_for :event_recurrences
  accepts_nested_attributes_for :event_cancellations

  attr_accessor :all_day

  validates :title, length: {maximum: 128}, presence: true
  validates :starts_at, date: true, allow_blank: true
  validates :starts_at, presence: true, unless: Proc.new {|model| model.all_day && model.starts_at.present?}
  validates :ends_at, date: true, allow_blank: true
  validates :all_day, allow_blank: true, inclusion: {in: [true, false], message: I18n.t('events.should_be_true_or_false')}
  validates :separation, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true
  validates :count, numericality: { only_integer: true }, allow_blank: true
  validates :until, date: true, allow_blank: true
  validates :notes, length: {maximum: 2048}
  validates :kind, allow_blank: true, numericality: {only_integer: true}
  validates :longitude, numericality: {only_integer: false, greater_than_or_equal_to: -180, less_than_or_equal_to: 180}, allow_blank: true
  validates :latitude, numericality: {only_integer: false, greater_than_or_equal_to: -90, less_than_or_equal_to: 90}, allow_blank: true
  validates :frequency, inclusion: {in: %w(once daily weekly monthly yearly)}

  validate :dates_check
  validate :recurrency_check

  default :separation, 1
  default :notes, ''
  default :kind, 0

  before_save do
    assign_attributes(starts_on: starts_at, ends_on: nil) if all_day && starts_at.present?
  end

  def muted
    me = muted_events.first
    me.present? && me.muted?
  end

private
  def recurrency_check
    if frequency == 'once' && event_recurrences.size > 0
      errors.add(:frequency, I18n.t('events.incorrect_once_event_reccurences'))
    end

    # if frequency != 'weekly' && event_recurrences.empty?
    #   event_recurrences.each do |er|
    #     if er.week.nil? && er.month.nil?
    #       if er.day.nil?
    #         errors.add(:frequency, 'You must specify a day of week for every recurency if you want to repeat event weekly')
    #         break
    #       end
    #     else
    #       errors.add(:frequency, 'You cannot specify week or month for weekly event, day is allowed only')
    #       break
    #     end
    #   end
    # end
  end

  def dates_check
    errors.add(:ends_at, I18n.t('events.start_date_not_end_date')) if starts_at == ends_at
    errors.add(:ends_at, I18n.t('events.start_date_more_than_end_date')) if ends_at.present? && starts_at.present? && (starts_at > ends_at)
  end

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER PATH: model Event
  # ================================================================================

  swagger_schema :Event do
    key :type, :object
    property :id do
      key :type, :integer
      key :description, 'Calendar item ID'
    end
    property :title do
      key :type, :string
      key :description, 'Calendar item title'
    end
    property :user_id do
      key :type, :number
      key :description, 'User ID who created this event'
    end
    property :starts_at do
      key :type, :string
      key :format, 'date-time'
      key :description, 'Start date and time for event'
    end
    property :ends_at do
      key :type, :string
      key :format, 'date-time'
      key :description, 'End date and time for event'
    end
    property :all_day do
      key :type, :boolean
      key :description, "Specifies all-day event. If it's true so ends_at is being set to null"
      key :default, false
    end
    property :notes do
      key :type, :string
      key :description, 'Additional notes'
    end
    property :timezone_name do
      key :type, :string
      key :description, 'Optional time zone to apply to starting and ending dates.
For reminders time zone usually does not matter'
    end
    property :kind do
      key :type, :integer
      key :format, :int16
      key :description, 'Enumeration specifies the type of calendar item'
      key :default, 0
    end
    property :latitude do
      key :type, :number
      key :format, :double
      key :description, 'Location lattitude'
    end
    property :longitude do
      key :type, :number
      key :format, :double
      key :description, 'Location longitude'
    end
    property :location_name do
      key :type, :string
      key :description, 'Location name. It might be city name, neighborhood name or anything else'
    end
    property :muted do
      key :type, :boolean
      key :description, 'Shows whether user receives notifications related to this event'
    end
    property :event_recurrences_attributes do
      key :type, :array
      items do
        key :'$ref', '#/definitions/EventReccurence'
      end
    end
    property :event_cancellations_attributes do
      key :type, :array
      items do
        key :'$ref', '#/definitions/EventCancellation'
      end
    end
    property :list do
      key :'$ref', '#/definitions/List'
    end
  end # end swagger_schema :Event

  # swagger_schema :ArrayOfEvents
  swagger_schema :ArrayOfEvents do
    key :type, :array
    items do
      key :'$ref', '#/definitions/Event'
    end
  end # end swagger_schema :ArrayOfEvents

  # swagger_schema :EventsContainer
  swagger_schema :EventsContainer do
    key :type, :object
    property :items do
      key :type, :array
      key :description, 'List of items created by current user'
      items do
        key :'$ref', '#/definitions/Event'
      end
    end
    property :shared_items do
      key :type, :array
      key :description, 'List of items shared with current user'
      items do
        key :'$ref', '#/definitions/Event'
      end
    end
  end # end swagger_schema :EventsContainer

  #swagger_schema :EventReccurence
  swagger_schema :EventReccurence do
    key :type, :object
    property :id do
      key :type, :integer
    end
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
  end # end swagger_schema EventReccurence

  # swagger_schema :EventCancellation
  swagger_schema :EventCancellation do
    key :type, :object
    property :id do
      key :type, :integer
    end
    property :date do
      key :type, :string
      key :format, 'date-time'
    end
  end # end swagger_schema :EventCancellation

  # swagger_schema :EventInput
  swagger_schema :EventInput do
    key :type, :object
    property :title do
      key :type, :string
      key :description, "Event's title"
    end
    property :starts_at do
      key :type, :string
      key :format, 'date-time'
      key :description, 'Start date and time for event'
    end
    property :ends_at do
      key :type, :string
      key :format, 'date-time'
      key :description, 'End date and time for event'
    end
    property :all_day do
      key :type, :boolean
      key :description, "Specifies all-day event. If it's true so ends_at is being set to null"
      key :default, false
    end
    property :notes do
      key :type, :string
      key :description, 'Additional notes'
    end
    property :timezone_name do
      key :type, :string
      key :description, 'Optional time zone to apply to starting and ending dates. For reminders time zone usually
does not matter'
    end
    property :kind do
      key :type, :integer
      key :format, :int16
      key :description, 'Enumeration specifies the type of event'
      key :default, 0
    end
    property :latitude do
      key :type, :number
      key :format, :double
      key :description, 'Location lattitude'
    end
    property :longitude do
      key :type, :number
      key :format, :double
      key :description, 'Location longitude'
    end
    property :location_name do
      key :type, :string
      key :description, 'Location name. It might be city name, neighborhood name or anything else'
    end
    property :separation do
      key :type, :number
      key :default, 1
      key :description, "The number of intervals at en event's frequency in between occurrences of
the event. For instance, if an event occurs every other week, it has a
frequency of weekly and a separation of 2 because there are 2 weeks in
between occurrences. This property defaults to 1"
    end
    property :count do
      key :type, :number
      key :description, 'Specifies a limit number of times the event will occur. Set this property to
NULL for no limit'
    end
    property :until do
      key :type, :string
      key :format, 'date-time'
      key :description, 'Specifies a limiting date and time after which no recurrences will be
generated for this event. Set this property to NULL for no limit'
    end
    property :frequency do
      key :type, :string
      key :description, "This property specifies the frequency at which this event recurs.
Possible values are 'once', 'daily', 'weekly', 'monthly', and 'yearly'"
    end
    property :event_recurrences_attributes do
      key :type, :array
      items do
        key :'$ref', '#/definitions/EventReccurenceInput'
      end
    end
    property :event_cancellations_attributes do
      key :type, :array
      items do
        key :'$ref', '#/definitions/EventCancellationInput'
      end
    end
  end # end swagger_schema :EventInput

end
