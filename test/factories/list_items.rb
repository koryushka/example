FactoryGirl.define do
  factory :list_item do
=begin
  title character varying(128) NOT NULL,
  notes character varying(2048) NOT NULL DEFAULT ''::character varying,
  "order" integer NOT NULL DEFAULT 0,
  list_id integer NOT NULL,
  done boolean NOT NULL DEFAULT false
=end
    title {Faker::Lorem.word}
    list
    notes {Faker::Lorem.paragraphs(1)}
  end
end