module Recurrence
  def self.included(base)
    puts 'Recurrence IS INCLUDED'
  end

  def calculate_event_recurrence
    case @frequence[:FREQ]
      when 'DAILY'  then manage_daily_event_recurrence
      when 'WEEKLY' then manage_weekly_event_recurrence
      when 'MONTHLY'then manage_monthly_event_recurrence
      when 'YEARLY' then manage_yearly_event_recurrence
    end
  end

  def manage_daily_event_recurrence( util_date =      @frequence[:UNTIL],
                                     count =    @frequence[:COUNT],
                                     interval = @frequence[:INTERVAL] || 1)
    @event.update_attributes(until: until_date(util_date),
                             count: count, separation: interval)
  end

  def until_date(date=nil)
    date.to_date if date
  end

  def manage_weekly_event_recurrence(util_date = @frequence[:UNTIL],
                                     count =     @frequence[:COUNT],
                                     interval =  @frequence[:INTERVAL] || 1)
    days = @frequence[:BYDAY].split(',')
    days.map do |day|
      find_or_create_event_recurrence(nil, nil, get_day(day))
    end
    @event.update_attributes(until: until_date(util_date),
                             count: count, separation: interval)

  end

  def manage_monthly_event_recurrence(util_date = @frequence[:UNTIL],
                                     count =     @frequence[:COUNT],
                                     interval =  @frequence[:INTERVAL] || 1)
    if byday = @frequence[:BYDAY]
      days = byday.split(',')
      days.map do |day|
        day.squish!
        find_or_create_event_recurrence(nil, day.slice!(0).to_i, get_day(day))
      end
    else
      find_or_create_event_recurrence(nil, nil, @event.starts_at.day)
    end
    @event.update_attributes(until: until_date(util_date),
                             count: count, separation: interval)
  end

  def manage_yearly_event_recurrence
    date = @event.starts_at.to_date
    find_or_create_event_recurrence(date.month, nil, date.day)
  end

  def find_or_create_event_recurrence(month, week, day)
    EventRecurrence.find_or_create_by(
      event_id: @event.id,
      month: month,
      week: week,
      day: day
    )
  end

  #Google

  def count_google_recurrence
    recurrences = @event.event_recurrences
    if recurrences
      get_recurrences(recurrences)
      puts "RECURRENCES_array #{@months}, #{@weeks}, #{@days}"
    else

    end
  end

  def get_recurrences(recurrences)
    %w(month week day).each do |period|
      instance_variable_set("@#{period}s", recurrences.pluck(period.to_sym))
    end
  end
end
