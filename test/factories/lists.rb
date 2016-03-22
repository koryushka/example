FactoryGirl.define do
  factory :list do
=begin
  title character varying(128) NOT NULL,
  user_id integer NOT NULL,
  notes character varying(2048) NOT NULL DEFAULT ''::character varying,
  kind smallint
=end
    title {Faker::Lorem.word}
    user nil
    notes {Faker::Lorem.paragraphs(1)}
    kind 1

    factory :list_with_items do
      after(:create) do |list|
        create_list(:list_item, 5, list: list)
      end
    end
  end
end