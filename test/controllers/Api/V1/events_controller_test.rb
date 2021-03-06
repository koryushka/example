require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::EventsControllerTest < ActionController::TestCase
  include AuthenticatedUser

  test 'should get index' do
    amount = 5
    FactoryGirl.create_list(:event, amount, user: @user)
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
    count = json_response.size
    assert count == 5, "Expected #{amount} updated events, #{count} given"
  end

  test 'should get show' do
    event = FactoryGirl.create(:event, user: @user)
    get :show, id: event.id
    assert_response :success
    assert_not_nil json_response
  end

  test 'should show event to participant' do
    user = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: user)
    FactoryGirl.create(:participation, participationable: event, sender: user, user: @user)

    get :show, id: event.id
    assert_response :success
    assert_not_nil json_response
  end

  test 'should show partial event data for family member if event is private' do
    owner = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: owner, public: false)
    group = FactoryGirl.create(:group, user: owner)
    group.create_participation(owner, @user)

    get :show, id: event.id
    assert_response :success
    assert_equal 'Busy', json_response['title']
    assert_nil json_response['user_id']
  end

  #### Event creation group
  test 'should create new regular event' do
    post :create, {
        title: Faker::Lorem.word,
        starts_at: Date.yesterday,
        ends_at: Date.yesterday + 1.hour,
        notes: Faker::Lorem.sentence(4),
        frequency: 'once',
        latitude: Faker::Address.latitude,
        longitude: Faker::Address.longitude
    }

    assert_response :success
    assert_not_nil json_response['id']
  end

  test 'should fail invalid event creation' do
    post :create
    assert_response :bad_request
  end

  test 'should create with nulled attributes replaced by defaults' do
    post :create, {
        title: Faker::Lorem.word,
        starts_at: Date.yesterday,
        ends_at: Date.yesterday + 1.hour,
        notes: Faker::Lorem.sentence(4),
        frequency: 'once',
        all_day: nil,
        separetion: nil,
        kind: nil
    }

    assert_response :success
    assert_not_nil json_response['id']
    assert_not_nil json_response['all_day']
    assert_not_nil json_response['separation']
    assert_not_nil json_response['kind']
  end

  test 'should create all-day event' do
    post :create, {
        title: Faker::Lorem.word,
        starts_at: Date.yesterday,
        all_day: true,
        notes: Faker::Lorem.sentence(4),
        frequency: 'once'
    }

    assert_response :success
    assert json_response['all_day']
  end

  #### Event update group
  test 'should update existing event' do
    event = FactoryGirl.create(:event, user: @user)
    new_title = Faker::Lorem.sentence(3)
    put :update, id: event.id, title: new_title
    assert_response :success
    assert_equal json_response['title'], new_title
    assert_not_equal json_response['title'], event.title
  end

  test 'should update all_day attribute' do
    event = FactoryGirl.create(:event, user: @user)
    put :update, id: event.id, all_day: true
    assert_response :success
    assert json_response['all_day']

    put :update, id: event.id, all_day: false
    assert_response :success
    assert_not json_response['all_day']
  end

  test 'should fail event update with invalid data' do
    event = FactoryGirl.create(:event, user: @user)
    put :update, id: event.id, title: nil
    assert_response :bad_request
  end

  test 'should fail to update event for non member user and not participant' do
    user = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: user)
    new_title = Faker::Lorem.sentence(3)
    put :update, id: event.id, title: new_title
    assert_response :forbidden
  end

  test 'should update event if user is a member of the family' do
    user = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: user)
    group = FactoryGirl.create(:group, owner: user)
    group.create_participation(user, @user)
    new_title = Faker::Lorem.sentence(3)
    put :update, id: event.id, title: new_title
    assert_response :success
    assert_equal new_title, json_response['title']
    assert_not_equal json_response['title'], event.title
  end

  test 'should not be able to update private event if user is a family member' do
    user = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: user, public: false)
    group = FactoryGirl.create(:group, owner: user)
    group.create_participation(user, @user)
    new_title = Faker::Lorem.sentence(3)
    put :update, id: event.id, title: new_title
    assert_response :forbidden
  end

  test 'should fail to show event for non member user' do
    user = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: user)
    get :show, id: event.id
    assert_response :forbidden
  end

  test 'should show event if user is a member of the family' do
    user = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: user)
    group = FactoryGirl.create(:group, owner: user)
    group.create_participation(user, @user)
    get :show, id: event.id
    assert_response :success
    assert_not_nil json_response
  end

  test 'should be able to update event status if I am owner' do
    event = FactoryGirl.create(:event, user: @user, public: true)
    put :update, id: event.id, public: false
    assert_response :success
  end

  test 'should not be able to update event status if I am family member' do
    event_owner = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: event_owner, public: true)
    group = FactoryGirl.create(:group, owner: event_owner)
    group.create_participation(event_owner, @user)
    put :update, id: event.id, public: false
    assert_response :forbidden
  end

  test 'should not be able to update event status if I am participant' do
    event_owner = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: event_owner, public: true)
    FactoryGirl.create(:participation,
                       participationable: event,
                       user: @user,
                       sender: event_owner,
                       status: Participation::ACCEPTED)
    put :update, id: event.id, public: false
    assert_response :forbidden
  end

  #### Event destroying group
  test 'should destroy existing event' do
    event = FactoryGirl.create(:event, user: @user)
    delete :destroy, id: event.id
    assert_response :no_content
    assert_raises ActiveRecord::RecordNotFound do
      Event.find(event.id)
    end
  end

  test 'should destroy existing event with cancellations and recurrencies' do
    event = FactoryGirl.create(:repeating_event_with_cancellation, user: @user)
    delete :destroy, id: event.id
    assert_response :no_content
    assert_raises ActiveRecord::RecordNotFound do
      Event.find(event.id)
    end
  end

  test 'should not destroy event of other user' do
    other_user = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: other_user)
    delete :destroy, id: event.id
    assert_response :forbidden
  end

  #### Calendar and events manipulation group
  test 'should add event to calendar' do
    calendar = FactoryGirl.create(:calendar, user: @user)
    event = FactoryGirl.create(:event, user: @user)
    post :add_to_calendar, calendar_id: calendar.id, id: event.id
    assert_response :success
    assert assigns(:calendar).events.where(id: event.id).size > 0
  end

  # test 'should not add event to calendar twice' do
  #   calendar = FactoryGirl.create(:calendar, user: @user)
  #   event = FactoryGirl.create(:event, user: @user)
  #   calendar.events << event
  #   post :add_to_calendar, calendar_id: calendar.id, id: event.id
  #   assert_response :not_acceptable
  # end

  # test 'should remove item from calendar' do
  #   calendar = FactoryGirl.create(:calendar, user: @user)
  #   event = FactoryGirl.create(:event, user: @user)
  #   calendar.events << event
  #   delete :remove_from_calendar, calendar_id: calendar.id, id: event.id
  #   assert_response :success
  #   assert_equal assigns(:calendar).events.where(id: event.id).size, 0
  # end

  test 'should get show_items' do
    calendar = FactoryGirl.create(:calendar, user: @user)
    event = FactoryGirl.create(:event, user: @user)
    calendar.events << event

    get :index_of_calendar, calendar_id: calendar.id
    assert_response :success
    assert json_response.size > 0
  end

  # test 'should get last updates' do
  #   calendar = FactoryGirl.create(:calendar, user: @user)
  #   (1..5).each do |n|
  #     calendar.events << FactoryGirl.create(:event, user: @user, title: "Event #{n}", updated_at: Time.now - 1.week)
  #   end
  #   calendar.events[3].title = 'Event 4 - updated'
  #   calendar.events[3].save
  #   calendar.events[4].title = 'Event 5 - updated'
  #   calendar.events[4].save
  #
  #   get :index_of_calendar, calendar_id: calendar.id, since: Date.today - 3.days
  #   assert_response :success
  #   assert_not_nil json_response['items']
  #   assert_not_nil json_response['shared_items']
  #   count = json_response['items'].size + json_response['shared_items'].size
  #   assert_equal 2, count
  # end

  #### lists group
  test 'should assign list to event' do
    event = FactoryGirl.create(:event, user: @user)
    list = FactoryGirl.create(:list, user: @user)

    post :add_list, id: event.id, list_id: list.id
    assert_response :success

    event.reload
    assert_equal list.id, event.list_id
  end

  test 'should remove list from event' do
    list = FactoryGirl.create(:list, user: @user)
    event = FactoryGirl.create(:event, user: @user, list: list)

    delete :remove_list, id: event.id, list_id: list.id
    assert_response :no_content

    event.reload
    assert_nil event.list
  end

  test 'should show events from specified list' do
    list = FactoryGirl.create(:list, user: @user)
    amount = 5
    FactoryGirl.create_list(:event, amount, user: @user, list: list)

    get :index_of_list, list_id: list.id
    assert_response :success
    assert_equal amount, json_response.size
  end

  test 'should attach list to public event if I am family member' do
    event_owner = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: event_owner, public: true)
    group = FactoryGirl.create(:group, owner: event_owner)
    group.create_participation(event_owner, @user)
    list = FactoryGirl.create(:list, user: @user)

    post :add_list, id: event.id, list_id: list.id
    assert_response :success

    event.reload
    assert_equal list.id, event.list_id
  end

  test 'should not be able to attach list to private event if I am family member' do
    event_owner = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: event_owner, public: false)
    group = FactoryGirl.create(:group, owner: event_owner)
    group.create_participation(event_owner, @user)
    list = FactoryGirl.create(:list, user: @user)

    post :add_list, id: event.id, list_id: list.id
    assert_response :forbidden
  end

  test 'should attach list to event if I am event participant' do
    event_owner = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: event_owner, public: true)
    list = FactoryGirl.create(:list, user: @user)
    FactoryGirl.create(:participation,
                       participationable: event,
                       user: @user,
                       sender: event_owner,
                       status: Participation::ACCEPTED)


    post :add_list, id: event.id, list_id: list.id
    assert_response :success

    event.reload
    assert_equal list.id, event.list_id

    private_event = FactoryGirl.create(:event, user: event_owner, public: false)
    FactoryGirl.create(:participation,
                       participationable: private_event,
                       user: @user,
                       sender: event_owner,
                       status: Participation::ACCEPTED)

    post :add_list, id: private_event.id, list_id: list.id
    assert_response :success

    private_event.reload
    assert_equal list.id, private_event.list_id
  end

  test 'should not be able to attach private list to an event' do
    event_owner = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: event_owner)
    FactoryGirl.create(:participation,
                       participationable: event,
                       user: @user,
                       sender: event_owner,
                       status: Participation::ACCEPTED)
    list = FactoryGirl.create(:list, user: @user, public: false)

    post :add_list, id: event.id, list_id: list.id
    assert_response :forbidden
  end

  #### mute/unmute group
  test 'should mute event notifications' do
    event = FactoryGirl.create(:event, user: @user)

    post :mute, id: event.id
    assert_response :success
    assert event.muted_events.exists?(muted_events: {user_id: @user.id, muted: true})
  end

  test 'should unmute event notifications' do
    event = FactoryGirl.create(:event, user: @user)
    me = MutedEvent.create(user: @user, event: event, muted: true)

    delete :unmute, id: event.id
    assert_response :success

    me.reload
    assert !me.muted?
  end
end
