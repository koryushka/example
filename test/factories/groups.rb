FactoryGirl.define do
  factory :group do

    title {Faker::Lorem.word}
    owner nil

    factory :group_with_members do
      transient do
        members_count 5
      end
      after(:create) do |group, evaluator|
        group.members << create_list(:user, evaluator.members_count)
      end
    end
  end
end