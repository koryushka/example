json.extract! group, :id, :title
json.array! group.members do |user|
  json.extract! user, :id, :email
end

