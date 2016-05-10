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

  # test 'should get bad request creating second main calendar' do
  #   FactoryGirl.create(:calendar, user: @user, main: true)
  #   post :create, {
  #       title: Faker::Lorem.word,
  #       user: @user,
  #       main: true
  #   }
  #   assert_response :not_acceptable
  # end

  #### Calendar update group
  test 'should upadte existing calendar' do
    calendar = FactoryGirl.create(:calendar, user: @user)
    new_title = 'New title'
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

  # test 'should fail setting second main calendar' do
  #   FactoryGirl.create(:calendar, user: @user, main: true)
  #   regular_calendar = FactoryGirl.create(:calendar, user: @user)
  #   post :update, id: regular_calendar.id, main: true
  #   assert_response :not_acceptable
  # end

  #### Calendar destroying group
  test 'should destroy existing calendar' do
    calendar = FactoryGirl.create(:calendar, user: @user)
    delete :destroy, id: calendar.id
    assert_response :no_content
    assert_raises ActiveRecord::RecordNotFound do
      Calendar.find(calendar.id)
    end
  end
end
