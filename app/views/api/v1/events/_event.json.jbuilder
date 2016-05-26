json.partial! 'api/v1/events/base_event', event: event
#json.all_day event.starts_on.present? && event.ends_on.nil?
json.list do
  json.partial! 'api/v1/lists/list', list: event.list
end if event.list.present?
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
json.participations do
  json.array! event.participations, partial: 'api/v1/participations/participation', as: :participation
end
