require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::ListsControllerTest < ActionController::TestCase
  include AuthenticatedUser

  test 'should get index of lists' do
    amount = 5
    FactoryGirl.create_list(:list, amount, user: @user)

    get :index
    assert_response :success
    assert_not_nil assigns(:lists)
    count = assigns(:lists).size
    assert_equal count, amount
  end

  test 'should get index of lists with items within' do
    items_count = 5
    FactoryGirl.create(:list_with_items, items_count: items_count, user: @user)

    get :index
    assert_response :success
    assert_not_nil response.body

    lists = JSON.parse(response.body)
    items = lists.first['items']
    assert_not_nil items

    count = items.size
    assert_equal count, items_count
  end

  test 'should get show' do
    list = FactoryGirl.create(:list, user: @user)
    get :show, id: list.id
    assert_response :success
    assert_not_nil assigns(:list)
  end

  #### list creation group
  test 'should create new list' do
    post :create, {
        title: Faker::Lorem.word,
        notes: Faker::Lorem.sentence(4),
        kind: 1
    }

    assert_response :success
    assert_not_nil assigns(:list).id
  end

  test 'should fail invalid list creation' do
    post :create
    assert_response :bad_request
  end

  #### list update group
  test 'should upadte existing list' do
    list = FactoryGirl.create(:list, user: @user)
    new_title = Faker::Lorem.word
    put :update, id: list.id, title: new_title
    assert_response :success
    assert_equal assigns(:list).title, new_title
    assert_not_equal assigns(:list).title, list.title
  end

  test 'should fail list update with invalid data' do
    list = FactoryGirl.create(:list, user: @user)
    put :update, id: list.id, title: nil
    assert_response :bad_request
  end

  #### list destroying group
  test 'should destroy existing list' do
    list = FactoryGirl.create(:list, user: @user)
    delete :destroy, id: list.id
    assert_response :no_content
    assert_raises ActiveRecord::RecordNotFound do
      List.find(list.id)
    end
  end

  test 'should destroy existing not empty list' do
    list = FactoryGirl.create(:list_with_items, items_count: 5, user: @user)
    delete :destroy, id: list.id
    assert_response :no_content
    assert_raises ActiveRecord::RecordNotFound do
      List.find(list.id)
    end
  end
end
