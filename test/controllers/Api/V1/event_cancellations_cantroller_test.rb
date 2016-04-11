require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::EventCancellationsControllerTest < ActionController::TestCase
  include AuthenticatedUser

  setup do
    @event = FactoryGirl.create(:event)
  end

  #### event_cancellation creation group
  test 'should create new event_cancellation' do
    post :create, event_id: @event.id, date: @event.starts_at + 1.week

    assert_response :success
    assert_not_nil json_response['id']
  end

  test 'should fail invalid event_cancellation creation' do
    post :create, event_id: @event.id
    assert_response :bad_request
  end

  #### event_cancellation update group
  test 'should upadte existing event_cancellation' do
    event_cancellation = FactoryGirl.create(:event_cancellation, event: @event)
    new_date = event_cancellation.date + 1.day
    put :update, id: event_cancellation.id, date: new_date
    assert_response :success
    assert_equal json_response['date'], new_date.strftime('%F')
    assert_not_equal json_response['date'], event_cancellation.date.strftime('%F')
  end

  test 'should fail event_cancellation update with invalid data' do
    event_cancellation = FactoryGirl.create(:event_cancellation, event: @event)
    put :update, id: event_cancellation.id, date: nil
    assert_response :bad_request
  end

  #### event_cancellation destroying group
  test 'should destroy existing event_cancellation' do
    event_cancellation = FactoryGirl.create(:event_cancellation, event: @event)
    delete :destroy, id: event_cancellation.id
    assert_response :no_content
    assert_raises ActiveRecord::RecordNotFound do
      EventCancellation.find(event_cancellation.id)
    end
  end
end