json.extract! list, :id, :title, :user_id, :notes, :kind
json.items do
   json.array! list.list_items, partial: 'api/v1/list_items/list_item', as: :list_item
end
json.participations do
  json.array! list.participations, partial: 'api/v1/participations/participation', as: :participation
end