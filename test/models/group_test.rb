require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test 'should accept participations to group' do
    participation = FactoryGirl.create(:participation_with_participationable, participationable_type: :group)

    group = participation.participationable
    group.accept_participation(participation)
    assert group.members.exists?(id: participation.user.id)
  end
end
