json.extract! activity, :id, :activity_type
json.kind activity.notificationable_type
json.activity_object do
  partial_name = activity.notificationable_type.downcase
  controller_path = activity.notificationable_type.underscore.pluralize
  partial_path = "api/v1/#{controller_path}/#{partial_name}"
  json.partial! partial_path, "#{partial_name}": activity.notificationable
end
