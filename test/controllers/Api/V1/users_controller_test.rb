require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::UsersControllerTest < ActionController::TestCase
  include AuthenticatedUser

  # Users groups management
  test 'should show users from specified group' do
    members_count = 5
    group = FactoryGirl.create(:group_with_members, owner: @user, members_count: members_count)
    get  :group_index, group_id: group.id
    assert_response :success
    assert_not_nil assigns(:members)
    assert_equal assigns(:members).size, members_count
  end

  test 'should show empty group' do
    group = FactoryGirl.create(:group, owner: @user)
    get  :group_index, group_id: group.id
    assert_response :success
    assert_not_nil assigns(:members)
    assert_equal assigns(:members).size, 0
  end

  test 'should add user to group' do
    group = FactoryGirl.create(:group, owner: @user)
    user = FactoryGirl.create(:user)

    post :add_to_group, group_id: group.id, id: user.id
    assert_response :success

    member = assigns(:group).members.first
    assert_not_nil member
    assert_equal member.id, user.id
  end

  test 'should remove user from group' do
    group = FactoryGirl.create(:group_with_members, owner: @user, members_count: 1)
    user = group.members.first

    delete :remove_from_group, group_id: group.id, id: user.id
    assert_response :no_content
    assert_equal assigns(:group).members.size, 0
  end
end
