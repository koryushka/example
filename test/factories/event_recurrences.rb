FactoryGirl.define do
  factory :event_recurrence do
=begin
  event_id integer,
  month integer,
  day integer,
  week integer,
=end
    event
    day {Faker::Number.between(0, 6)}
    week {Faker::Number.between(1, 4)}
    month {Faker::Number.between(1, 12)}
  end
end
