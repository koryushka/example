require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::FilesControllerTest < ActionController::TestCase
  include AuthenticatedUser

  test 'should show specified file object' do
    file = FactoryGirl.create(:uploaded_file)
    get :show, id: file.id
    assert_response :success
    assert_not_nil json_response
    assert_not_nil json_response['id']
  end

  test 'should upload file' do
    post :create, file: fixture_file_upload('img24.jpg', 'image/jpeg', :binary)
    assert_response :success
    assert_not_nil json_response
    assert_not_nil json_response['id']
  end

  test 'should delete uploaded file' do
    file = FactoryGirl.create(:uploaded_file)
    delete :destroy, id: file.id
    assert_response :no_content
  end
end
