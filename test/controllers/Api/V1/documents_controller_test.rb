require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::DocumentsControllerTest < ActionController::TestCase
  include AuthenticatedUser

  test 'should get index' do
    event = FactoryGirl.create(:event, user: @user)
    document = FactoryGirl.create(:document, user: @user)
    event.documents << document
    get :index, event_id: event.id
    assert_response :success
    assert_not_nil assigns(:documents)
    assert assigns(:documents).size() == 1
  end

  test 'should get show' do
    document = FactoryGirl.create(:document, user: @user)
    get :show, id: document.id
    assert_response :success
    assert_not_nil assigns(:document)
  end

  #### Document creation group
  test 'should create new regular document' do
    uploaded_file = FactoryGirl.create(:uploaded_file)
    post :create, {
        title: Faker::Lorem.word,
        notes: Faker::Lorem.sentence(4),
        uploaded_file_id: uploaded_file.id
    }

    assert_response :success
    assert_not_nil assigns(:document).id
  end

  test 'should fail invalid document creation' do
    post :create
    assert_response :bad_request
  end

  #### Document update group
  test 'should upadte existing document' do
    document = FactoryGirl.create(:document, user: @user)
    new_title = Faker::Lorem.sentence(3)
    put :update, id: document.id, title: new_title
    assert_response :success
    assert_equal assigns(:document).title, new_title
    assert_not_equal assigns(:document).title, document.title
  end

  test 'should fail document update with invalid data' do
    document = FactoryGirl.create(:document, user: @user)
    put :update, id: document.id, title: nil
    assert_response :bad_request
  end

  #### Document destroying group
  test 'should destroy existing document' do
    document = FactoryGirl.create(:document, user: @user)
    delete :destroy, id: document.id
    assert_response :no_content
    assert_raises ActiveRecord::RecordNotFound do
      Document.find(document.id)
    end
  end
end