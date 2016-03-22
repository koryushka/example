require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::ListItemsControllerTest < ActionController::TestCase
  include AuthenticatedUser

  test 'should get index' do
    list = FactoryGirl.create(:list_with_items, user: @user)
    get :index, list_id: list.id
    assert_response :success
    assert_not_nil assigns(:list_items)
    assert assigns(:list_items).size() > 0
  end

  test 'should get show' do
    list = FactoryGirl.create(:list_with_items, user: @user)
    get :show, id: list.items.first.id
    assert_response :success
    assert_not_nil assigns(:list_item)
  end

  #### list_item creation group
  test 'should create new regular list_item' do
    list = FactoryGirl.create(:list, user: @user)
    post :create, {
        title: Faker::Lorem.word,
        notes: Faker::Lorem.sentence(4),
        list_id: list.id
    }

    assert_response :success
    assert_not_nil assigns(:list_item).id
  end

  test 'should fail invalid list_item creation' do
    list = FactoryGirl.create(:list, user: @user)
    post :create, list_id: list.id
    assert_response :bad_request
  end

  #### list_item update group
  test 'should upadte existing list_item' do
    list = FactoryGirl.create(:list_with_items, user: @user)
    list_item = list.items.first
    new_title = Faker::Lorem.word
    put :update, id: list_item.id, title: new_title
    assert_response :success
    assert_equal assigns(:list_item).title, new_title
    assert_not_equal assigns(:list_item).title, list_item.title
  end

  test 'should fail list_item update with invalid data' do
    list = FactoryGirl.create(:list_with_items, user: @user)
    list_item = list.items.first
    put :update, id: list_item.id, title: nil
    assert_response :bad_request
  end

  #### list_item destroying group
  test 'should destroy existing list_item' do
    list = FactoryGirl.create(:list_with_items, user: @user)
    list_item = list.items.first
    delete :destroy, id: list_item.id
    assert_response :no_content
    assert_raises ActiveRecord::RecordNotFound do
      ListItem.find(list_item.id)
    end
  end
end
