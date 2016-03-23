require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::EventsControllerTest < ActionController::TestCase
  include AuthenticatedUser

  test 'should get index' do
    amount = 5
    FactoryGirl.create_list(:event, amount, user: @user)
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
    count = assigns(:events).size()
    assert count == 5, "Expected #{amount} updated events, #{count} given"
  end

  test 'should get show' do
    event = FactoryGirl.create(:event, user: @user)
    get :show, id: event.id
    assert_response :success
    assert_not_nil assigns(:event)
  end

  #### Event creation group
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

  #### Event update group
  test 'should upadte existing event' do
    event = FactoryGirl.create(:event, user: @user)
    new_title = Faker::Lorem.sentence(3)
    put :update, id: event.id, title: new_title
    assert_response :success
    assert_equal assigns(:event).title, new_title
    assert_not_equal assigns(:event).title, event.title
  end

  test 'should fail event update with invalid data' do
    event = FactoryGirl.create(:event, user: @user)
    put :update, id: event.id, title: nil
    assert_response :bad_request
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

  #### Document attaching group
  test 'should attach existing document to existing event' do
    event = FactoryGirl.create(:event, user: @user)
    document = FactoryGirl.create(:document, user: @user)
    post :attach_document, id: event.id, document_id: document.id
    assert_response :success
    assert assigns(:event).documents.where(id: document.id).size() > 0
  end

  #### Document detaching group
  test 'should detach document attached earlier from event' do
    event = FactoryGirl.create(:event, user: @user)
    document = FactoryGirl.create(:document, user: @user)
    event.documents << document
    delete :detach_document, id: event.id, document_id: document.id
    assert_response :success
    assert assigns(:event).documents.where(id: document.id).size() == 0
  end
end
