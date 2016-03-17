require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::EventsControllerTest < ActionController::TestCase
  include AuthenticatedUser

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test 'should get show' do
    event = FactoryGirl.create(:event, user: @user)
    get :show, id: event.id
    assert_response :success
    assert_not_nil assigns(:event)
  end

  test 'should create new regular event' do
    post :create, {
        title: Faker::Lorem.word,
        starts_at: Date.yesterday,
        ends_at: Date.yesterday + 1.hour,
        notes: Faker::Lorem.sentence(4),
        frequency: 'once'
    }

    assert_response :success
    assert_not_nil assigns(:event).id
  end

  test 'should fail invalid event creation' do
    post :create
    assert_response :bad_request
  end
end
