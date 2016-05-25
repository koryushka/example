require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::ApidocsControllerTest < ActionController::TestCase
  test 'should get documentation json' do
    get :index
    assert_response :success
    assert json_response
  end
end
