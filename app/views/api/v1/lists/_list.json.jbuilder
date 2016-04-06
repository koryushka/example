json.extract! list, :id, :title, :user_id, :notes, :kind
json.items do
   json.array! list.items, partial: 'item', as: :list_item
end