# event attributes
json.extract! event, :id, :starts_at, :ends_at

if can? :view_private, event
  json.extract! event, :title, :user_id, :notes, :timezone_name, :kind,
                :latitude, :longitude, :location_name, :separation,
                :count, :until, :frequency, :updated_at, :muted, :all_day,
                :image_url, :public, :recurring_event_id
else
  json.title 'Busy'
end