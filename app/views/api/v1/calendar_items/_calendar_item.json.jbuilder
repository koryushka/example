json.extract! calendar_item, :id, :title, :start_date, :end_date, :notes, :read_only, :timezone, :kind, :latitude, :longitude, :location_name
json.creator calendar_item.user.user_name