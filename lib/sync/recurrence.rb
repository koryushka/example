module Recurrence

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

  def count_google_recurrence
    recurrences = @event.event_recurrences
    if recurrences
      get_recurrences(recurrences)
    else

    end
  end

  def get_recurrences(recurrences)
    %w(month week day).each do |period|
      instance_variable_set("@#{period}s", recurrences.pluck(period.to_sym))
    end
  end
end
