FactoryGirl.define do
  factory :user do
    email {Faker::Internet.email}
    password {Faker::Internet.password}

    factory :user_with_profile do
      after(:create) do |user|
        create(:profile, user: user)
      end
    end
  end
end
