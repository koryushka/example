require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::GroupsParticipationsTest < ActionController::TestCase
  tests ParticipationsController
  include AuthenticatedUser

  test 'should add user from other family into the mine with participation failed status' do
    user = FactoryGirl.create(:user)
    other_group_owner = FactoryGirl.create(:user)
    other_group = FactoryGirl.create(:group, user: other_group_owner)
    other_group.participations << Participation.new(user: user,
                                                    sender: other_group_owner,
                                                    status: Participation::ACCEPTED)
    group = FactoryGirl.create(:group, user: @user)
    post :create, group_id: group.id, user_ids: [user.id]
    assert_response :success
    assert_equal 1, group.participations.where(status: Participation::FAILED).size
  end

  test 'should add other family owner into the mine with participation failed status' do
    other_group_owner = FactoryGirl.create(:user)
    FactoryGirl.create(:group, user: other_group_owner)
    group = FactoryGirl.create(:group, user: @user)

    post :create, group_id: group.id, user_ids: [other_group_owner.id]
    assert_response :success
    assert_equal 1, group.participations.where(status: Participation::FAILED).size
  end

  test 'should be able invite user after failed invitation' do
    participant = FactoryGirl.create(:user)
    group2 = FactoryGirl.create(:group, user: @user)
    FactoryGirl.create(:participation,
                       participationable: group2,
                       user: participant,
                       sender: @user,
                       status: Participation::FAILED)

    post :create, group_id: group2.id, user_ids: [participant.id]
    assert_response :success
    assert group2.participations.exists?(user: participant,
                                         sender: @user,
                                         status: Participation::ACCEPTED)
  end
end