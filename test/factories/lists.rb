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
      transient do
        items_count 1
      end
      after(:create) do |list, evaluator|
        create_list(:list_item, evaluator.items_count, list: list, user: list.user)
      end
    end
  end
end