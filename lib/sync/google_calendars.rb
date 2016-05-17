class GoogleCalendars
  include Recurrence
  include Googleable
  attr_accessor :items

  def initialize(current_user, service, account)
    @current_user, @service, @account = current_user, service, account
    @items = []
  end

  def import_calendars
    @calendar_list = @service.list_calendar_lists
    calendars = []
    @calendar_list.items.each do |item|
      @calendar = Calendar.find_or_initialize_by(
        google_calendar_id: item.id,
        title: item.summary,
        user_id: @current_user.id,
        account: @account
      )
      if @calendar.should_be_synchronised?
        if @calendar.new_record? && @calendar.save
          calendars << @calendar
        end
        parse_events_from_calendar
      end
    end
  end

  private

  def parse_events_from_calendar
    @google_calendar_events = @service.list_events(@calendar.google_calendar_id).items
    @i ||= 0
    @google_calendar_events.each do |item|
      @i += 1
      puts "#{@i} - EVENT #{item.summary} - ID #{item.id}"
      @items << item
      @event = Event.find_or_initialize_by(google_event_uniq_id: item.i_cal_uid) do |event|
        event.google_event_id = item.id
        event.calendar_id = @calendar.id
        event.etag = item.etag
        event.starts_at = start_date item
        event.ends_at = end_date item
        event.title = title item
        event.frequency = get_frequency item
        event.user_id = @current_user.id
        event.location_name = item.location
      end

      if @event.new_record?
        @event.save
      else
        if !cancelled?(item)
          next if user_is_not_creator(item)
          next unless synchronize_event(item)
        end
      end

      if @frequence && @event.persisted?
        calculate_event_recurrence
      end
      create_event_cancellation(item) if cancelled?(item)
      @frequence = nil if @frequence
    end
  end

  def synchronize_event(item)
    puts
    puts "EVENT UPDATED AT #{@event.try(:updated_at)}"
    puts "ITEM UPDATED AT #{item.try(:updated)} - CALENDAR_ID - #{@calendar.title}- ID #{item.id} title #{item.summary}"
    if @event.etag != item.etag
      update_local_event(item)
    else
      if (@event.updated_at > item.updated) && (@event.updated_at != @event.created_at)
        updated_google_event = update_google_event(item)
        @event.update_column(:etag, updated_google_event.etag) if updated_google_event.try(:etag)
      end
    end
  end

  def update_local_event(item)
    if single_event_has_recurrences(item) || frequency_has_been_changed(item)
      destroy_event_reccurences
    end
    @event.update_attributes(
      starts_at: start_date(item),
      ends_at: item.end.date_time,
      timezone_name: item.start.try(:time_zone) || @event.timezone_name,
      notes: item.description,
      title: title(item),
      frequency: get_frequency(item),
      user_id: @current_user.id,
      google_event_id: item.id,
      location_name: item.location,
      etag: item.etag
    )
    calculate_event_recurrence if @frequence
    puts 'LOCAL EVENT HAS BEEN UPDATED'
  end

  def update_google_event(item)
    @update_errors = []
    begin
      google_event = @service.get_event(@calendar.google_calendar_id, @event.google_event_id)
      google_event.update!(
        start: {
          date_time: formatted_date(@event.starts_at) ,
          time_zone: @event.timezone_name
        },
        end:{
          date_time: formatted_date(@event.ends_at) ,
          time_zone: @event.timezone_name
        },
        # recurrence: count_google_recurrence,
        location: @event.location_name,
        description: @event.notes,
        summary: @event.title
      )
      updated_event = @service.update_event(@calendar.google_calendar_id, @event.google_event_id, google_event)
      puts 'GOOGLE EVENT HAS BEEN UPDATED'
      updated_event
    rescue Google::Apis::ClientError => error
      @update_errors << [error, google_event]
    end
  end

  def frequency_has_been_changed(item)
    get_frequency(item) != @event.frequency
  end

  def destroy_event_reccurences
    @event.event_recurrences.destroy_all
  end

  def single_event_has_recurrences(item)
    (!item.recurrence) && @event.event_recurrences
  end

  def formatted_date(date)
    date.to_datetime.strftime("%FT%T%:z") if date
  end

  def user_is_not_creator(item)
    item.creator.email != @account
  end

  def public_event(item)
    item.visibility == 'public'
  end

  def create_event_cancellation(item)
    EventCancellation.find_or_create_by(
      event_id: @event.id,
      date: item.original_start_time.date_time.to_date
    )
  end

  def get_day(day)
   week = {
      'SU' => 0,'MO' => 1,'TU' => 2,'WE' => 3,'TH' => 4,'FR' => 5,'SA' => 6
    }
    week[day]
  end

  def get_frequency(item)
    if item.recurrence
      @frequence = count_frequency(item.recurrence[0])
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
    puts "ITEM #{item.inspect}"
    if cancelled?(item)
      Event.find_by_google_event_id(item.recurring_event_id).title
    else
      item.summary || 'Untitled event'
    end
  end

  def cancelled?(item)
    item.status == 'cancelled'
  end

end
