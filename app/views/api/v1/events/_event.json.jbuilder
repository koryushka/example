json.extract! event, :id, :title, :user_id, :starts_at, :ends_at, :notes,
                     :timezone_name, :kind, :latitude, :longitude, :location_name,
                     :separation, :count, :until, :frequency, :updated_at, :muted,
                     :recurring_event_id
json.all_day event.starts_on.present? && event.ends_on.nil?
json.list do
  json.partial! 'api/v1/lists/list', list: event.list
end if event.list.present?
json.participations do
  json.array! event.participations, partial: 'api/v1/participations/participation', as: :participation
end

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
