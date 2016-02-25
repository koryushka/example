json.items do
  json.array! @calendar.calendar_items, partial: 'api/v1/calendar_items/calendar_item', as: :calendar_item
end
json.shared_items do
  json.array! @calendar.shared_items, partial: 'api/v1/calendar_items/calendar_item', as: :calendar_item
end
