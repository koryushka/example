json.items do
  json.array! @calendar.complex_events, partial: 'api/v1/events/event', as: :event
end
json.shared_items do
  json.array! @calendar.shared_events, partial: 'api/v1/events/event', as: :event
end
