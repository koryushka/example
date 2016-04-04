require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::GroupsControllerTest < ActionController::TestCase
  include AuthenticatedUser

  test 'should get index' do
    groups_count = 5
    FactoryGirl.create_list(:group, groups_count, owner: @user)
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
    assert assigns(:groups).size == groups_count
  end

  test 'should get show' do
    group = FactoryGirl.create(:group, owner: @user)
    get :show, id: group.id
    assert_response :success
    assert_not_nil assigns(:group)
  end

  #### group creation group
  test 'should create new group' do
    post :create, {
        title: Faker::Lorem.word
    }

    assert_response :success
    assert_not_nil assigns(:group).id
  end

  test 'should fail invalid group creation' do
    post :create, {
        title: 'x'*200
    }
    assert_response :bad_request
  end

  #### group update group
  test 'should upadte existing group' do
    group = FactoryGirl.create(:group, owner: @user)
    new_title = Faker::Lorem.word
    put :update, id: group.id, title: new_title
    assert_response :success
    assert_equal assigns(:group).title, new_title
    assert_not_equal assigns(:group).title, group.title
  end

  test 'should fail group update with invalid data' do
    group = FactoryGirl.create(:group, owner: @user)
    put :update, id: group.id, title: nil
    assert_response :bad_request
  end

  #### group destroying group
  test 'should destroy existing group' do
    group = FactoryGirl.create(:group, owner: @user)
    delete :destroy, id: group.id
    assert_response :no_content
    assert_raises ActiveRecord::RecordNotFound do
      ListItem.find(group.id)
    end
  end
end
