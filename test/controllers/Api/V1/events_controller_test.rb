require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::EventsControllerTest < ActionController::TestCase
  setup do
    User.create id: 5, provider: 'email', uid: 'templar8@gmail.com', password: '12341234', email: 'templar8@gmail.com'
  end

  test 'should get index' do
    get :index, format: :json
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test 'should get show' do
    get :show, format: :json, id: events(:event1).id
    assert_response :success
    assert_not_nil assigns(:event)
  end
end
