json.extract! group, :id, :title
json.owner_id group.user_id
json.participations do
  json.array! group.participations, partial: 'api/v1/participations/participation', as: :participation
end

