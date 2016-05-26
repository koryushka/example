json.accounts @accounts do |item|
  json.extract! item, :id, :account, :revoked, :synchronizable
  json.calendars  item.calendars do |calendar|
    json.extract! calendar, :id, :title
    json.synchronizable calendar.synchronizable
  end
end
