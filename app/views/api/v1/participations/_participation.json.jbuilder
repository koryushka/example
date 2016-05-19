json.extract! participation, :id, :email, :status
json.kind participation.participationable_type
json.user do
  json.partial! 'api/v1/users/with_profile_only', user: participation.user
end if participation.user_id.present?
json.sender do
  json.partial! 'api/v1/users/with_profile_only', user: participation.sender
end