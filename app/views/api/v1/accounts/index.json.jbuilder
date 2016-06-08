json.array! @accounts do |item|
  json.extract! item, :id, :account_name, :revoked, :synchronizable
  json.calendars  item.calendars do |calendar|
    json.extract! calendar, :id, :title, :color
    json.synchronizable calendar.synchronizable
  end
end
