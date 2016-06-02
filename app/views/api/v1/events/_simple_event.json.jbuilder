# excluded unnecessary relations
json.partial! 'api/v1/events/base_event', event: event
json.user do
  json.partial! 'api/v1/users/with_profile_only', user: event.user
end
json.list do
  json.partial! 'api/v1/lists/list', list: event.list
end if event.list.present?
json.participations do
  json.array! event.participations, partial: 'api/v1/participations/participation', as: :participation
end
