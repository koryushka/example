require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test 'should accept participations to group' do
    participation = FactoryGirl.create(:participation_with_participationable, participationable_type: :group)

    group = participation.participationable
    group.accept_participation(participation)
    assert group.members.exists?(id: participation.user.id)
  end

  test 'should add participations to group' do
    sender1 = FactoryGirl.create(:user)
    group1 = FactoryGirl.create(:group, user: sender1)
    participant1 = FactoryGirl.create(:user)

    group1.create_participation(sender1, participant1)
    assert Participation.exists?(sender: sender1,
                                 user: participant1,
                                 participationable_type: Group.name,
                                 status: Participation::ACCEPTED)

    sender2 = FactoryGirl.create(:user)
    group2 = FactoryGirl.create(:group, user: sender2)
    participant2 = FactoryGirl.create(:user)
    group2.create_participation(sender2, participant2)
    group1.create_participation(sender1, participant2)
    assert Participation.exists?(sender: sender1,
                                 user: participant2,
                                 participationable_type: Group.name,
                                 status: Participation::FAILED)
  end

  test 'should get members' do
    owner = FactoryGirl.create(:user)
    group = FactoryGirl.create(:group, owner: owner)
    participations_count = 5
    participations_count.times.each do
      participant = FactoryGirl.create(:user)
      FactoryGirl.create(:participation, participationable: group, user: participant, status: Participation::ACCEPTED)
    end

    assert_equal participations_count + 1, group.members.size
  end
end
