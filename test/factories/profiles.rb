FactoryGirl.define do
  factory :profile do
    user nil
    full_name {Faker::Name.name}
    image_url {Faker::Avatar.image}
    color {Faker::Color.hex_color[1..6]}
  end
end
