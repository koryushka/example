json.extract! user, :id, :email
json.profile do
  json.partial! 'api/v1/profiles/profile', profile: user.profile
end if user.profile
json.group do
  json.partial! 'api/v1/groups/group_without_users', group: user.participated_group
end if user.participated_group
