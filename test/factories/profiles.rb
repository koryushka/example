FactoryGirl.define do
  factory :profile do
    user nil
    first_name {Faker::Name.first_name}
    last_name {Faker::Name.last_name}
    image_url {Faker::Avatar.image}
    color {Faker::Color.hex_color[1..6]}
  end
end
