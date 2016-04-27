json.extract! event, :id, :title, :user_id, :starts_at, :ends_at, :notes,
                     :timezone_name, :kind, :latitude, :longitude, :location_name,
                     :separation, :count, :until, :frequency, :updated_at
json.all_day event.starts_on.present? && event.ends_on.nil?
json.muted
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