require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::CalendarsControllerTest < ActionController::TestCase
  include AuthenticatedUser

  #### Getting data group
  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:calendars)
  end

  test 'should get show' do
    calendar = FactoryGirl.create(:calendar, user: @user)
    get :show, id: calendar.id
    assert_response :success
    assert_not_nil assigns(:calendar)
  end

  test 'should get show_items' do
    calendar = FactoryGirl.create(:calendar, user: @user)
    event = FactoryGirl.create(:event, user: @user)
    calendar.events << event

    get :show_items, id: calendar.id
    assert_response :success
    assert assigns(:calendar).events.size() > 0
  end

  #### Calendars creation group
  test 'should create new calendar' do
    post :create, {
      title: Faker::Lorem.word,
      user: @user,
      hex_color: Faker::Color.hex_color[1..-1]
    }
    assert_response :success
    assert_not_nil assigns(:calendar).id
  end

  test 'should fail invalid calendar creation' do
    post :create
    assert_response :bad_request
  end

  #### Calendar update group
  test 'should upadte existing calendar' do
    calendar = FactoryGirl.create(:calendar, user: @user)
    new_title = Faker::Lorem.word
    put :update, id: calendar.id, title: new_title
    assert_response :success
    assert_equal assigns(:calendar).title, new_title
    assert_not_equal assigns(:calendar).title, calendar.title
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
    post :add_item, id: calendar.id, item_id: event.id
    assert_response :success
    assert assigns(:calendar).events.where(id: event.id).size() > 0
  end

  test 'should remove item from calendar' do
    calendar = FactoryGirl.create(:calendar, user: @user)
    event = FactoryGirl.create(:event, user: @user)
    calendar.events << event
    delete :remove_item, id: calendar.id, item_id: event.id
    assert_response :success
    assert assigns(:calendar).events.where(id: event.id).size() == 0
  end

end