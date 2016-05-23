json.extract! child_event, :id, :title, :user_id, :starts_at, :ends_at, :notes,
                     :timezone_name, :kind, :latitude, :longitude, :location_name,
                     :separation, :count, :until, :frequency, :updated_at, :muted,
                     :recurring_event_id
json.all_day child_event.starts_on.present? && child_event.ends_on.nil?
json.list do
  json.partial! 'api/v1/lists/list', list: child_event.list
end if child_event.list.present?
json.participations do
  json.array! child_event.participations, partial: 'api/v1/participations/participation', as: :participation
end
