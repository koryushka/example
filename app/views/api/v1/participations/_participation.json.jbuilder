json.extract! participation, :id, :email, :status
json.kind participation.participationable_type
json.user do
  json.partial! 'api/v1/users/user', user: participation.user
end if participation.user_id.present?
json.sender do
  json.partial! 'api/v1/users/user', user: participation.sender
end