FactoryGirl.define do
  factory :uploaded_file do
=begin
  public_url character varying(2048) NOT NULL,
  key character varying(512) NOT NULL
=end
    public_url Faker::Internet.url
    key Faker::Lorem.characters(32)
  end
end