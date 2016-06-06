json.partial! 'api/v1/events/base_event', event: event
json.list do
  json.partial! 'api/v1/lists/list', list: child_event.list
end if child_event.list.present?
json.participations do
  json.array! child_event.participations, partial: 'api/v1/participations/participation', as: :participation
end
