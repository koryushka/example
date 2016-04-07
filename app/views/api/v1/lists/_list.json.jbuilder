json.extract! list, :id, :title, :user_id, :notes, :kind
json.items do
   json.array! list.list_items, partial: 'api/v1/list_items/list_item', as: :list_item
end