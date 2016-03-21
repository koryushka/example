FactoryGirl.define do
  factory :event_cancellation do
    event
    date {event.starts_at + 1.week}
  end
end