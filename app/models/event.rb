class Event < AbstractModel
  include GoogleAuth
  include Swagger::Blocks

  belongs_to :user
  belongs_to :calendar
  # has_and_belongs_to_many :calendars
  has_and_belongs_to_many :documents, counter_cache: true
  has_many :event_recurrences, dependent: :destroy
  has_many :event_cancellations, dependent: :destroy
  belongs_to :list
  has_many :muted_events
  has_many :participations, as: :participationable, dependent: :destroy
  has_many :activities, as: :notificationable, dependent: :destroy
  has_many :child_events, class_name: 'Event', foreign_key: 'recurring_event_id', dependent: :destroy
  belongs_to :parent_event, class_name: 'Event', foreign_key: 'recurring_event_id'#, counter_cache: true
  has_one :muted_event, -> (user) {where(user_id: user.id)}


  # TODO: must optimise this scope
  scope :with_muted, -> (user_id){joins("LEFT JOIN muted_events ON muted_events.event_id = events.id AND muted_events.user_id = #{user_id}")}

  accepts_nested_attributes_for :event_recurrences
  accepts_nested_attributes_for :event_cancellations

  validates :title, length: {maximum: 128}, presence: true
  validates :starts_at, date: true, allow_blank: true
  validates :starts_at, presence: true, unless: Proc.new {|model| model.all_day && model.starts_at.present?}
  validates :ends_at, date: true, allow_blank: true
  validates :all_day, allow_blank: true, inclusion: {in: [true, false], message: I18n.t('events.should_be_true_or_false')}
  validates :separation, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true
  validates :count, numericality: { only_integer: true }, allow_blank: true
  validates :until, date: true, allow_blank: true
  # validates :notes, length: {maximum: 2048}
  validates :kind, allow_blank: true, numericality: {only_integer: true}
  validates :longitude, numericality: {only_integer: false, greater_than_or_equal_to: -180, less_than_or_equal_to: 180}, allow_blank: true
  validates :latitude, numericality: {only_integer: false, greater_than_or_equal_to: -90, less_than_or_equal_to: 90}, allow_blank: true
  validates :frequency, inclusion: {in: %w(once daily weekly monthly yearly)}
  validates :image_url, length: {maximum: 2048}

  validate :dates_check
  validate :recurrency_check

  default :separation, 1
  default :notes, ''
  default :kind, 0
  default :all_day, false
  default :public, true

  @changed_attributes = nil
  before_save do
    assign_attributes(starts_on: starts_at, ends_on: nil) if all_day && starts_at.present?
    assign_attributes(starts_on: nil, ends_on: nil) unless all_day
    @changed_attributes = changes
  end

  after_save do
    next unless @changed_attributes.present?

    user_ids = [user_id] # event owner

    if !public? && ![:starts_at, :starts_on, :ends_at, :ends_on].all? { |k| !@changed_attributes.key?(k) }

      user_ids << participations.where(status: Participation::ACCEPTED)
                      .pluck(:user_id) # participants with status pending/accepted
    else
      user_ids << participations.where.not(status: Participation::DECLINED)
                      .where.not(status: Participation::FAILED)
                      .pluck(:user_id) # participants with status accepted
      # My Family Members & My Family Creator
      family = user.family
      user_ids << user.family.members.pluck(:id) if family.present?
    end

    user_ids.uniq.each do |user_id|
      PubnubHelper::Publisher.publish(@changed_attributes, user_id)
    end

    @changed_attributes = nil
  end

  # after_destroy :destroy_from_google, if: :has_etag?
  # after_update :update_google_event, if: :has_etag?

  ACTIVITY_TYPES = [UPDATED = 1]
  after_update do
    participations.where(status: Participation::ACCEPTED).each do |p|
      Activity.create(notificationable: self, user: p.user, activity_type: UPDATED)
    end
  end

  def self.all_of_user(user_id, range_start, range_end, time_zone, filter)
    params = [user_id, range_start, filter, range_end, time_zone].map do |param|
      param.nil? ? 'NULL' : sanitize(param)
    end.join(', ')
    sql = "(SELECT * FROM recurring_events_for(#{params})) events"
    from(sql)
  end

  def muted
    me = muted_events.first
    me.present? && me.muted?
  end

  def private?
    !public?
  end
  #
  # def destroy
  #   super
  #   if self.etag
  #     destroy_from_google
  #   end
  # end

  def destroy_from_google
    calendar = self.calendar
    google_access_token = GoogleAccessToken.find_by_account_name(calendar.account)
    if google_access_token && calendar.should_be_synchronised?
      authorize google_access_token
      begin
        @service.delete_event(calendar.google_calendar_id, self.google_event_id)
      rescue Google::Apis::ClientError => error
      end
    end
  end

  def create_participation(sender, user)
    participation = Participation.create(user: user, sender: sender, participationable: self)
    family_member = sender.family && sender.family.participations.exists?(user: user)
    if family_member
      participation.change_status_to(Participation::ACCEPTED)
    else
      ParticipationsMailer.invitation(participation).deliver_now
    end

    notify_members

    participation
  end

  def update_google_event(user_id)
    calendar = self.calendar
    google_access_token = GoogleAccessToken.find_by(account_name: calendar.account, user_id: user_id)
    if google_access_token && calendar.should_be_synchronised?
      authorize google_access_token
      params = {
        start: {
          date_time: self.starts_at.to_datetime,
          time_zone: self.timezone_name
        },
        end:{
          date_time: self.ends_at.to_datetime,
          time_zone: self.timezone_name
        },
        # recurrence: count_google_recurrence,
        location: self.location_name,
        description: self.notes,
        summary: self.title
      }
      begin
        google_event = @service.get_event(calendar.google_calendar_id, self.google_event_id)
        google_event.update!(params)
        updated_event = @service.update_event(calendar.google_calendar_id, self.google_event_id, google_event)
        puts 'GOOGLE EVENT HAS BEEN UPDATED'
        self.update_column(:etag, updated_event.etag)
        updated_event
      rescue Google::Apis::ClientError => error
      end
    end
  end

private

  def count_google_recurrence

  end

  # def formatted_date(date)
  #   date.to_datetime.strftime("%FT%T%:z") if date
  # end

  def has_etag?
    self.etag
  end

  def notify_members
    users_ids = [participations.pluck(:user_id), user_id]
    family = user.family
    users_ids << family.members.pluck(:id) if family.present?

    users_ids.flatten.uniq.each do |user_id|
      PubnubHelper::Publisher.publish('event participation changed', user_id)
    end
  end

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

  swagger_schema :EventInput do
    key :type, :object
    key :required, [:title, :starts_at]
    property :title do
      key :type, :string
      key :description, 'Event\'s title'
      key :maxLength, 128
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
    property :image_url do
      key :type, :string
      key :description, 'Contains link to event picture'
      key :maxLength, 2048
    end
    property :public do
      key :type, :boolean
      key :description, "Specifies event. If it's true so All family members should be able to modify all attributes
of the event with the exception of changing the ‘Public’ / ‘Private’ setting"
      key :default, true
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
        key :'$ref', :EventCancellationInput
      end
    end
  end

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
    property :image_url do
      key :type, :string
      key :description, 'Contains link to event picture'
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
        key :'$ref', :EventCancellation
      end
    end
    property :list do
      key :'$ref', :List
    end
    property :user do
      key :'$ref', :UserWithProfileOnly
    end
    property :participations do
      key :type, :array
      items do
        key :'$ref', :Participation
      end
    end
    property :public do
      key :type, :boolean
      key :description, "Specifies event. If it's true so All family members should be able to modify all attributes
of the event with the exception of changing the ‘Public’ / ‘Private’ setting"
      key :default, true
    end
  end # end swagger_schema :Event

  # swagger_schema :ArrayOfEvents
  swagger_schema :ArrayOfEvents do
    key :type, :array
    items do
      key :'$ref', :Event
    end
  end # end swagger_schema :ArrayOfEvents

  # swagger_schema :EventsContainer
  swagger_schema :EventsContainer do
    key :type, :object
    property :items do
      key :type, :array
      key :description, 'List of items created by current user'
      items do
        key :'$ref', :Event
      end
    end
    property :shared_items do
      key :type, :array
      key :description, 'List of items shared with current user'
      items do
        key :'$ref', :Event
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

  # swagger_schema :NotificationPreference
  swagger_schema :NotificationPreference do
    key :type, :object
    property :email do
      key :type, :boolean
      key :description, 'Preference for getting email notification'
      key :default, false
    end
    property :push do
      key :type, :boolean
      key :description, 'Preference for getting push notification'
      key :default, false
    end
    property :sms do
      key :type, :boolean
      key :description, 'Preference for getting sms notification'
      key :default, false
    end
  end # end swagger_schema :NotificationPreference


end
