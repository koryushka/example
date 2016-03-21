FactoryGirl.define do
  factory :calendar do
=begin
  title character varying(128) NOT NULL,
  user_id integer NOT NULL,
  hex_color character varying(6) NOT NULL DEFAULT ''::character varying,
  main boolean NOT NULL DEFAULT false,
  kind integer NOT NULL DEFAULT 0,
  visible boolean NOT NULL DEFAULT true
=end
    title Faker::Lorem.word
    user nil
    hex_color Faker::Color.hex_color[1..-1]
  end
end
