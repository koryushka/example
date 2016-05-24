FactoryGirl.define do
  factory :device do
=begin
  device_token hexadecimal(64) NOT NULL,
  aws_endpoint_arn string NOT NULL
=end
    device_token Faker::Number.hexadecimal(64)
  end
end
