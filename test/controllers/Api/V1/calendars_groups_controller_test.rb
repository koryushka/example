require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::CalendarsGroupsControllerTest < ActionController::TestCase
  include AuthenticatedUser

  test 'should get index' do
    amount = 5
    FactoryGirl.create_list(:calendars_group, amount, user: @user)
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
    count = assigns(:groups).size()
    assert count == 5, "Expected #{amount} updated events, #{count} given"
  end

  test 'should get show' do
    calendars_group = FactoryGirl.create(:calendars_group, user: @user)
    get :show, id: calendars_group.id
    assert_response :success
    assert_not_nil assigns(:calendars_group)
  end

  #### Event creation group
  test 'should create new calendar group' do
    post :create, {title: Faker::Lorem.word}
    assert_response :success
    assert_not_nil assigns(:calendars_group).id
  end

  test 'should fail invalid calendar group creation' do
    post :create
    assert_response :bad_request
  end

  #### Event update group
  test 'should upadte existing calendars_group' do
    calendars_group = FactoryGirl.create(:calendars_group, user: @user)
    new_title = Faker::Lorem.sentence(3)
    put :update, id: calendars_group.id, title: new_title
    assert_response :success
    assert_equal assigns(:calendars_group).title, new_title
    assert_not_equal assigns(:calendars_group).title, calendars_group.title
  end

  test 'should fail event update with invalid data' do
    calendars_group = FactoryGirl.create(:calendars_group, user: @user)
    put :update, id: calendars_group.id, title: nil
    assert_response :bad_request
  end

  #### Event destroying group
  test 'should destroy existing event' do
    calendars_group = FactoryGirl.create(:calendars_group, user: @user)
    delete :destroy, id: calendars_group.id
    assert_response :no_content
    assert_raises ActiveRecord::RecordNotFound do
      CalendarsGroup.find(calendars_group.id)
    end
  end
end