json.partial! 'api/v1/events/simple_event', event: event
#json.all_day event.starts_on.present? && event.ends_on.nil?
json.event_recurrences_attributes do
  json.array! event.event_recurrences do |er|
    json.extract! er, :id, :day, :week, :month
  end
end
json.event_cancellations_attributes do
  json.array! event.event_cancellations do |ec|
    json.extract! ec, :id, :date
  end
end
