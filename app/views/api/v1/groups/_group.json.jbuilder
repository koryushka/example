json.extract! group, :id, :title
json.owner do
  json.partial! 'api/v1/users/with_profile_only', user: group.owner
end
json.participations do
  json.array! group.participations, partial: 'api/v1/participations/participation', as: :participation
end

