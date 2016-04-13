require 'test_helper'


class EventTest < ActiveSupport::TestCase
  test 'should check dates_check' do
    date1 = Date.today
    date2 = Date.today - 1.day
    event1 = Event.new(title: Faker::Lorem.word, starts_at: date1, ends_at: date1, frequency: 'once')
    event2 = Event.new(title: Faker::Lorem.word, starts_at: date1, ends_at: date2, frequency: 'once')

    assert event1.invalid?
    assert event2.invalid?, 'Incorrect event dates validation. Event with ends_at < starts_at can be created'
  end
end
