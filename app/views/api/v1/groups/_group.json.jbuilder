json.extract! group, :id, :title
json.participations do
  json.array! group.participations, partial: 'api/v1/participations/participation', as: :participation
end

