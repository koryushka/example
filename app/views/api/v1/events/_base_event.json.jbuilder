# event attributes
json.extract! event, :id, :title, :user_id, :starts_at, :ends_at, :notes,
              :timezone_name, :kind, :latitude, :longitude, :location_name,
              :separation, :count, :until, :frequency, :updated_at,
              :muted, :all_day, :image_url, :public, :recurring_event_id