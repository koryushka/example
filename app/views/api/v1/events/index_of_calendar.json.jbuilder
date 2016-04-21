json.items do
  json.array! @events, partial: 'event', as: :event
end
json.shared_items do
  json.array! @shared_events, partial: 'event', as: :event
end
