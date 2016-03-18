FactoryGirl.define do
  factory :document do
=begin
  title character varying(128) NOT NULL,
  notes character varying(2048) NOT NULL DEFAULT ''::character varying,
  tags character varying(2048) NOT NULL DEFAULT ''::character varying,
  user_id integer NOT NULL,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  uploaded_file_id integer NOT NULL
=end
    title Faker::Lorem.word
    user nil
    notes Faker::Lorem.sentence(4)
    uploaded_file
  end
end