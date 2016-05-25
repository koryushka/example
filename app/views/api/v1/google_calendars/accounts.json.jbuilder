json.accounts @accounts do |item|
  json.extract! item, :id, :account
  json.syncronized item.deleted ? false : true
  json.calendars  item.calendars do |calendar|
    json.extract! calendar, :id, :title
    json.syncronized calendar.sync_with_google
  end
end
