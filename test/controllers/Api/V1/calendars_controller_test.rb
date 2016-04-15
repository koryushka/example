require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::CalendarsControllerTest < ActionController::TestCase
  include AuthenticatedUser

  #### Getting data group
  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil json_response
  end

  test 'should get show' do
    calendar = FactoryGirl.create(:calendar, user: @user)
    get :show, id: calendar.id
    assert_response :success
    assert_not_nil json_response
  end

  test 'should get show_items' do
    calendar = FactoryGirl.create(:calendar, user: @user)
    event = FactoryGirl.create(:event, user: @user)
    calendar.events << event

    get :show_items, id: calendar.id
    assert_response :success
    assert json_response.size > 0
  end

  test 'should get last updates' do
    calendar = FactoryGirl.create(:calendar, user: @user)
    (1..5).each do |n|
      calendar.events << FactoryGirl.create(:event, user: @user, title: "Event #{n}", updated_at: Time.now - 1.week)
    end
    calendar.events[3].title = 'Event 4 - updated'
    calendar.events[3].save
    calendar.events[4].title = 'Event 5 - updated'
    calendar.events[4].save

    get :show_items, id: calendar.id, since: Date.today - 3.days
    assert_response :success
    assert_not_nil json_response['items']
    assert_not_nil json_response['shared_items']
    count = json_response['items'].size + json_response['shared_items'].size
    assert count == 2, "Expected 2 updated events, #{count} given"
  end

  #### Calendars creation group
  test 'should create new calendar' do
    post :create, {
      title: Faker::Lorem.word,
      user: @user,
      hex_color: Faker::Color.hex_color[1..-1]
    }
    assert_response :success
    assert_not_nil json_response['id']
  end

  test 'should fail invalid calendar creation' do
    post :create
    assert_response :bad_request
  end

  test 'should get bad request creating second main calendar' do
    FactoryGirl.create(:calendar, user: @user, main: true)
    post :create, {
        title: Faker::Lorem.word,
        user: @user,
        main: true
    }
    assert_response :not_acceptable
  end

  #### Calendar update group
  test 'should upadte existing calendar' do
    calendar = FactoryGirl.create(:calendar, user: @user)
    new_title = Faker::Lorem.word
    put :update, id: calendar.id, title: new_title
    assert_response :success
    assert_equal json_response['title'], new_title
    assert_not_equal json_response['title'], calendar.title
  end

  test 'should fail calendar update with invalid data' do
    calendar = FactoryGirl.create(:calendar, user: @user)
    put :update, id: calendar.id, title: nil
    assert_response :bad_request
  end

  #### Calendar destroying group
  test 'should destroy existing calendar' do
    calendar = FactoryGirl.create(:calendar, user: @user)
    delete :destroy, id: calendar.id
    assert_response :no_content
    assert_raises ActiveRecord::RecordNotFound do
      Calendar.find(calendar.id)
    end
  end

  #### Calendar items manipulation group
  test 'should add event to calendar' do
    calendar = FactoryGirl.create(:calendar, user: @user)
    event = FactoryGirl.create(:event, user: @user)
    post :add_event, id: calendar.id, event_id: event.id
    assert_response :success
    assert assigns(:calendar).events.where(id: event.id).size > 0
  end

  test 'should not add event to calendar twice' do
    calendar = FactoryGirl.create(:calendar, user: @user)
    event = FactoryGirl.create(:event, user: @user)
    calendar.events << event
    post :add_event, id: calendar.id, event_id: event.id
    assert_response :not_acceptable
  end

  test 'should remove item from calendar' do
    calendar = FactoryGirl.create(:calendar, user: @user)
    event = FactoryGirl.create(:event, user: @user)
    calendar.events << event
    delete :remove_event, id: calendar.id, event_id: event.id
    assert_response :success
    assert assigns(:calendar).events.where(id: event.id).size == 0
  end

end
