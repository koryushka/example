# excluded unnecessary relations
json.extract! event, :id, :title, :user_id, :starts_at, :ends_at, :notes,
              :timezone_name, :kind, :latitude, :longitude, :location_name,
              :separation, :count, :until, :frequency, :updated_at,
              :muted, :all_day, :image_url, :public
json.list do
  json.partial! 'api/v1/lists/list', list: event.list
end if event.list.present?
json.participations do
  json.array! event.participations, partial: 'api/v1/participations/participation', as: :participation
end
