json.extract! user, :id, :email
json.profile do
  json.partial! 'api/v1/profiles/profile', profile: user.profile
end if user.profile
