FactoryGirl.define do
  factory :device do
=begin
  title character varying(128) NOT NULL,
  user_id integer NOT NULL,
  hex_color character varying(6) NOT NULL DEFAULT ''::character varying,
  main boolean NOT NULL DEFAULT false,
  kind integer NOT NULL DEFAULT 0,
  visible boolean NOT NULL DEFAULT true
=end
    user_id rand(1000)
    device_token Hash[*Faker::Lorem.words(4)]
    aws_endpoint_arn 'aws:sns:us-west-2:'+ Faker::Number.number(12) + ':' + 'MyTests:' +
                         Faker::Number.hexadecimal(8) + '-' +
                         Faker::Number.hexadecimal(4) + '-' +
                         Faker::Number.hexadecimal(4) + '-' +
                         Faker::Number.hexadecimal(4) + '-' +
                         Faker::Number.hexadecimal(12)
  end
end
