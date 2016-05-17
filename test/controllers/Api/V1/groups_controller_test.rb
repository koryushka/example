require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::GroupsControllerTest < ActionController::TestCase
  include AuthenticatedUser

=begin
  test 'should get index' do
    groups_count = 5
    FactoryGirl.create_list(:group, groups_count, owner: @user)
    get :index
    assert_response :success
    assert_not_nil json_response
    assert json_response.size == groups_count
  end
=end
  test 'should get family' do
    FactoryGirl.create(:group, owner: @user)
    get :index
    assert_response :success
    assert_not_nil json_response
  end

  test 'should get show' do
    group = FactoryGirl.create(:group, owner: @user)
    get :show, id: group.id
    assert_response :success
    assert_not_nil json_response
  end

  #### group creation group
  test 'should create new group' do
    post :create, {
        title: Faker::Lorem.word
    }

    assert_response :success
    assert_not_nil json_response['id']
  end

  test 'should fail invalid group creation' do
    post :create, {
        title: 'x'*200
    }
    assert_response :bad_request
  end

  test 'should fail group creation if user is owner of other group' do
    FactoryGirl.create(:group, user: @user)
    post :create, {
        title: Faker::Lorem.word
    }

    assert_response :conflict
  end

  test 'should fail group creation if user is a member of other group' do
    user = FactoryGirl.create(:user)
    group = FactoryGirl.create(:group, user: user)
    group.participations << Participation.new(user: @user, sender: user, status: Participation::ACCEPTED)
    post :create, {
        title: Faker::Lorem.word
    }

    assert_response :conflict
  end

  #### group update group
  test 'should upadte existing group' do
    group = FactoryGirl.create(:group, owner: @user)
    new_title = 'New title'
    put :update, id: group.id, title: new_title
    assert_response :success
    assert_equal json_response['title'], new_title
    assert_not_equal json_response['title'], group.title
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

  test 'should remove current user from group' do
    user = FactoryGirl.create(:user)
    group = FactoryGirl.create(:group, owner: user)
    group.members << @user

    delete :leave, id: group.id
    assert_response :success
    assert_not group.participations.exists?(user: @user)
  end
end
