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
      @calendar = Calendar.find_or_create_by(
        google_calendar_id: item.id,
        user_id: @current_user.id,

      ) do |calendar|
        calendar.title = item.summary
        calendar.account = @account
      end

      if @calendar.should_be_synchronised?
        parse_events_from_calendar
      end
    end
  end

  private

  def parse_events_from_calendar
    @google_calendar_events = @service.list_events(@calendar.google_calendar_id).items
    items_count = @service.list_events(@calendar.google_calendar_id).items.length
    @i ||= 0
    event_cancellations = []
    @google_calendar_events.each_with_index do |item, index|
      @i += 1
      puts "#{@i} - EVENT #{item.summary} - ID #{item.id}"
      @items << item
      get_frequency item
      if !item.recurring_event_id && !cancelled?(item)
        @event = Event.find_or_initialize_by(google_event_uniq_id: item.i_cal_uid) do |event|
          event.google_event_id = item.id
          event.calendar_id = @calendar.id
          event.etag = item.etag
          event.starts_at = start_date item
          event.ends_at = end_date item
          event.title = title item
          event.user_id = @current_user.id
          event.location_name = item.location
          event.frequency = @frequency
          event.notes = item.description
        end
      elsif item.recurring_event_id && cancelled?(item)
        @event = Event.find_by_google_event_id(item.recurring_event_id)
        event_cancellations << item
        if items_count == index + 1
          manage_events_cancellations(event_cancellations)
        end
        @frequence = nil if @frequence
        next
      elsif item.recurring_event_id && !cancelled?(item)
        #TODO compare with parent event to create single event(as a part of recurring events)
        @frequence = nil if @frequence
        next
      end

      if @event.new_record?
        assign_event_frequency_attributes if @frequence
        @event.save
        calculate_event_recurrence if @frequence
      else
        next if user_is_not_creator(item)
        next unless synchronize_event(item)
      end
      @frequence = nil if @frequence
    end
  end

  def manage_events_cancellations(event_cancellations)
    new_event_cancellations = []
    event_cancellations.each do |event_cancellation|
      event = Event.find_by_google_event_id(event_cancellation.recurring_event_id)
      puts "EVENT CANCELLATIONS ID #{event_cancellation}"
      new_event_cancellations << EventCancellation.new(date: get_event_cancellation_date(event_cancellation), event_id: event.id)
    end
    new_event_cancellations.group_by(&:event_id).each do |event_id, ec|
      Event.find(event_id).event_cancellations.destroy_all
      ec.each {|e| e.save}
    end
    puts "EVENT CANCELLATIONS #{new_event_cancellations}"
  end

  def synchronize_event(item)
    puts
    puts "EVENT UPDATED AT #{@event.try(:updated_at)}"
    puts "ITEM UPDATED AT #{item.try(:updated)} - CALENDAR_ID - #{@calendar.title}- ID #{item.id} title #{item.summary}"
    if google_event_was_updated?(item)
      update_local_event(item)
    # else
    #   if (@event.updated_at.to_datetime > item.updated.to_datetime) && (@event.updated_at != @event.created_at)
    #     updated_google_event = update_google_event(item)
    #     @event.update_columns(
    #       etag: updated_google_event.etag,
    #       updated_at: updated_google_event.updated) if updated_google_event.try(:etag)
      # end
    end
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
      etag: item.etag,
      notes: item.description
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

  def google_event_was_updated?(item)
    @event.etag != item.etag
  end

  def destroy_event_reccurences
    @event.event_recurrences.destroy_all
  end

  def destroy_event_cancellations
    @event.event_cancellations.destroy_all
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
      date: get_event_cancellation_date(item)
    )
  end

  def get_event_cancellation_date(item)
    start_time = item.original_start_time
    date_time = start_time.date_time
    date = start_time.date
    puts "datetime: #{date_time}"
    puts "date #{date}"
    result = date_time ? date_time.to_datetime : date.to_datetime
    result
  end

  def get_frequency(item)
    if item.recurrence
      @frequence = count_frequency(item.recurrence[0])
      @frequency = @frequence[:FREQ].downcase
    else
      @frequency ='once'
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
