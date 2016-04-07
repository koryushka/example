json.extract! group, :id, :title
json.members do
  json.array! group.members do |user|
    json.extract! user, :id, :email
  end
end

