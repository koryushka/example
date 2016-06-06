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

  test 'should check incorrect lat and long validation' do
    event = FactoryGirl.create(:event)
    event.longitude = -200
    assert event.invalid?

    event = FactoryGirl.create(:event)
    event.latitude = -100
    assert event.invalid?
  end

  test 'should check validation of incorrect recurrency' do
    event = FactoryGirl.create(:event, frequency: 'once')
    event.event_recurrences << EventRecurrence.new
    assert event.invalid?
  end

  test 'should accept invitation to event automatically for family member' do
    sender = FactoryGirl.create(:user)
    group = FactoryGirl.create(:group, user: sender)
    group.participations << Participation.new(sender: sender, user: @user, status: Participation::ACCEPTED)
    event = FactoryGirl.create(:event, user: sender)
    event.create_participation(sender, @user)

    assert event.participations.exists?(user: @user, status: Participation::ACCEPTED)
  end
end
