FactoryGirl.define do
  factory :device do
=begin
  device_token hexadecimal(64) NOT NULL,
  aws_endpoint_arn string NOT NULL
=end
    device_token Faker::Number.hexadecimal(64)
    aws_endpoint_arn 'arn:aws:sns:us-west-2:319846285652:endpoint/APNS_SANDBOX/curago_test/' +
                         Faker::Number.hexadecimal(8) + '-' +
                         Faker::Number.hexadecimal(4) + '-' +
                         Faker::Number.hexadecimal(4) + '-' +
                         Faker::Number.hexadecimal(4) + '-' +
                         Faker::Number.hexadecimal(12)
  end
end
