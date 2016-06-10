class GoogleCalendars
  include GoogleAuth
  attr_accessor :items

  def initialize(current_user, service, account)
    @current_user, @service, @account, @gat = current_user, service[0], account, service[1]
    @items = []
  end

  def import_calendars(calendar_id=nil, after_notification=nil)
    calendar_list = calendar_id ? [@service.get_calendar(calendar_id)] :
      @service.list_calendar_lists.items
    calendars = []
    calendar_list.each do |item|
      google_calendar = Calendar.find_or_create_by(
        google_calendar_id: item.id,
        google_access_token_id: @gat.id

      ) do |calendar|
        unless calendar_id
          calendar.color = item.background_color
          calendar.title = item.summary
          calendar.account = @account
          calendar.user_id = @current_user.id
        end
      end
      unless calendar_id
        if google_calendar.persisted? && calendar_attributes_changed?(item, google_calendar)
          google_calendar.update_attributes(
            color: item.background_color,
            title: item.summary,
            account: @account,
            user_id: @current_user.id
          )
        end
      end

      if google_calendar.should_be_synchronised?
        parse_events_from_calendar(google_calendar)
      end
    end
  end

  private
  def calendar_attributes_changed?(item, calendar)
    #add logic
    true
  end

  def parse_events_from_calendar(google_calendar)
    google_calendar_events = @service.list_events(google_calendar.google_calendar_id).items
    @items += google_calendar_events
    parent_events = google_calendar_events.select {|x| !cancelled?(x) && !x.recurring_event_id}
    cancelled_events = google_calendar_events.select {|x| x.recurring_event_id && cancelled?(x)}
    recurring_events = google_calendar_events.select {|x| x.recurring_event_id && !cancelled?(x)}

    event_cancellations = []
    #manage parent events
    parent_events.each do |item|
      remove_frequency
      @frequency = get_frequency item
      p "USER #{@current_user}"
      @event = Event.find_or_initialize_by(google_event_uniq_id: item.i_cal_uid, user_id: @current_user.id) do |event|
        event.google_event_id = item.id
        event.calendar_id = google_calendar.id
        event.etag = item.etag
        event.starts_at = start_date item
        event.ends_at = end_date item
        event.title = title item
        event.location_name = item.location
        event.frequency = @frequency
        event.notes = item.description
      end
      if @event.new_record?
        assign_event_frequency_attributes if @frequence
        @event.save
        calculate_event_recurrence if @frequence
      else
        next if user_is_not_creator(item)
        next unless synchronize_event(item)
      end
    end

    #manage event cancellations
    cancelled_events.group_by(&:recurring_event_id).each do |recurring_event_id, group|
      @event = Event.find_by(google_event_id: recurring_event_id, user_id: @current_user.id)
      group.each do |event_cancellation|
          create_event_cancellation(event_cancellation) if @event
      end
    end

    #manage recurring events(children)
    recurring_events.group_by(&:recurring_event_id).each do |recurring_event_id, group|
      @event = Event.find_by(google_event_id: recurring_event_id, user_id: @current_user.id)
      group.each do |child_event|
        unless parent_event_equal_to? child_event
          @child = Event.find_or_initialize_by(google_event_id: child_event.id, user_id: @current_user.id) do |event|
            event.recurring_event_id = @event.id
            event.notes = child_event.description
            event.title = child_event.summary
            event.starts_at = @s_date
            event.ends_at = @e_date
            event.frequency = 'once'
            event.calendar_id = @event.calendar_id
            event.google_event_uniq_id = @event.google_event_uniq_id
          end
          if @child.new_record?
            @child.save
          else
            update_changed_attributes(child_event)
          end
        end
      end

    end
  end

  def update_changed_attributes(child_event)
    attributes = build_changed_attributes(child_event)
    @child.update_attributes(attributes) if attributes.presence
  end

  def build_changed_attributes(child_event)
    changed_attributes = {}
    changed_attributes[:title] = child_event.summary if (child_event.summary != @child.title)
    changed_attributes[:notes] = child_event.description if (child_event.description != @child.notes)
    changed_attributes[:starts_at] = @s_date if (@s_date != @child.starts_at)
    changed_attributes[:ends_at] = @e_date if (@e_date != @child.ends_at)
    changed_attributes
  end

  def parent_event_equal_to?(child_event)
      @s_date = start_date child_event
      @e_date = end_date child_event
      (child_event.summary == @event.title) && (@s_date == @event.starts_at) &&
      (@e_date == @event.ends_at) && (child_event.description == @event.notes)
  end

  def synchronize_event(item)
    update_local_event(item) if google_event_was_updated?(item)
  end

  def update_local_event(item)
    destroy_event_reccurences
    destroy_event_cancellations
    assign_event_frequency_attributes if @frequence
    @event.update_attributes(
      starts_at: start_date(item),
      ends_at: item.end.date_time,
      timezone_name: item.start.try(:time_zone) || @event.timezone_name,
      notes: item.description,
      title: title(item),
      frequency: @frequency,
      user_id: @current_user.id,
      google_event_id: item.id,
      location_name: item.location,
      etag: item.etag
    )
    calculate_event_recurrence if @frequence
    puts 'LOCAL EVENT HAS BEEN UPDATED ' + @event.title
  end

  # def update_google_event(item)
  #   @update_errors = []
  #   begin
  #     google_event = @service.get_event(@calendar.google_calendar_id, @event.google_event_id)
  #     google_event.update!(
  #       start: {
  #         date_time: formatted_date(@event.starts_at) ,
  #         time_zone: @event.timezone_name
  #       },
  #       end:{
  #         date_time: formatted_date(@event.ends_at) ,
  #         time_zone: @event.timezone_name
  #       },
  #       # recurrence: count_google_recurrence,
  #       location: @event.location_name,
  #       description: @event.notes,
  #       summary: @event.title
  #     )
  #     updated_event = @service.update_event(@calendar.google_calendar_id, @event.google_event_id, google_event)
  #     puts 'GOOGLE EVENT HAS BEEN UPDATED'
  #     updated_event
  #   rescue Google::Apis::ClientError => error
  #     @update_errors << [error, google_event]
  #   end
  # end

  def google_event_was_updated?(item)
    @event.etag != item.etag
  end

  def destroy_event_reccurences
    @event.event_recurrences.destroy_all if @event && @event.event_recurrences
  end

  def destroy_event_cancellations
    @event.event_cancellations.destroy_all if @event && @event.event_cancellations
  end

  def user_is_not_creator(item)
    item.creator.email != @account
  end

  def create_event_cancellation(item)
    event = EventCancellation.find_or_create_by(
      event_id: @event.id,
      date: get_event_cancellation_date(item)
    )
    remove_cancelled_event(event)
  end

  def remove_cancelled_event(event)
    event_to_delete = Event.find_by('recurring_event_id = ? AND date(starts_at) = ? AND user_id = ?', @event.id, event.date, @current_user.id)
    event_to_delete.destroy if event_to_delete
  end

  def get_event_cancellation_date(item)
    start_time = item.original_start_time
    date_time = start_time.date_time
    date = start_time.date
    date_time ? date_time.to_datetime : date.to_datetime
  end

  def remove_frequency
    @frequence = nil if @frequence
    @frequency = nil if @frequency
  end

  def get_frequency(item)
    if item.recurrence
      recurrence = item.recurrence.select {|x| x.include?('RRULE')}[0]
      @frequence = count_frequency(recurrence)
      @frequence[:FREQ].downcase
    else
      'once'
    end
  end

  def count_frequency(recurrence)
    rules = recurrence.gsub('RRULE:','').split(';')
    hash = {}
    rules.map do |r|
      pair = r.split('=')
      hash[pair[0].to_sym] = pair[1]
    end
    hash
  end

  def start_date(item)
    if cancelled?(item)
      item.original_start_time.date_time
    else
      item.start.date || item.start.date_time
    end
  end

  def end_date(item)
    unless cancelled?(item)
      item.end.date || item.end.date_time
    end
  end

  def title(item)
    if cancelled?(item)
      Event.find_by_google_event_id(item.recurring_event_id).title
    else
      item.summary || 'Untitled event'
    end
  end

  def cancelled?(item)
    item.status == 'cancelled'
  end

  #Recurrence

  def calculate_event_recurrence
    case @frequence[:FREQ]
      when 'DAILY'  then manage_daily_event_recurrence
      when 'WEEKLY' then manage_weekly_event_recurrence
      when 'MONTHLY'then manage_monthly_event_recurrence
      when 'YEARLY' then manage_yearly_event_recurrence
    end
  end

  def manage_daily_event_recurrence
    assign_event_frequency_attributes(nil, nil, nil)
  end

  def manage_weekly_event_recurrence
    days = @frequence[:BYDAY].split(',')
    days.map do |day|
      find_or_create_event_recurrence(nil, nil, get_day(day))
    end
  end

  def manage_monthly_event_recurrence
    if byday = @frequence[:BYDAY]
      days = byday.split(',')
      days.map do |day|
        day.squish!
        find_or_create_event_recurrence(nil, get_week(day), get_day(day))
      end
    else
      find_or_create_event_recurrence(nil, nil, @event.starts_at.day)
    end
  end

  def manage_yearly_event_recurrence
    date = @event.starts_at.to_date
    find_or_create_event_recurrence(date.month, nil, date.day)

  end

  def assign_event_frequency_attributes(u_date = @frequence[:UNTIL],
                                        count =     @frequence[:COUNT],
                                        interval =  @frequence[:INTERVAL] || 1)
    @event.until      = until_date(u_date)
    @event.count      = count
    @event.separation = interval
  end

  def until_date(date=nil)
    date.to_date if date
  end

  def find_or_create_event_recurrence(month, week, day)
    EventRecurrence.find_or_create_by(
      event_id: @event.id,
      month: month,
      week: week,
      day: day
    )
  end

  def get_day(day)
   day = day.slice(-2..-1)
   week = {
      'SU' => 0,'MO' => 1,'TU' => 2,'WE' => 3,'TH' => 4,'FR' => 5,'SA' => 6
    }
    week[day]
  end

  def get_week(day)
    @day = day
    @day.start_with?('-') ? slice_day(0..1) : slice_day(1)
  end

  def slice_day(range)
    @day.slice(range).to_i
  end

  #Google

  # def count_google_recurrence
  #   recurrences = @event.event_recurrences
  #   if recurrences
  #     get_recurrences(recurrences)
  #   else
  #
  #   end
  # end
  #
  # def get_recurrences(recurrences)
  #   %w(month week day).each do |period|
  #     instance_variable_set("@#{period}s", recurrences.pluck(period.to_sym))
  #   end
  # end
end
