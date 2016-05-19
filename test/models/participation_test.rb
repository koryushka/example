require 'test_helper'

class ParticipationTest < ActiveSupport::TestCase
  test 'should check accepted?' do
    participation = FactoryGirl.create(:participation_with_participationable, participationable_type: :group)
    participation.status = Participation::ACCEPTED
    assert participation.accepted?
  end

  test 'should check declined?' do
    participation = FactoryGirl.create(:participation_with_participationable, participationable_type: :group)
    participation.status = Participation::DECLINED
    assert participation.declined?
  end

  test 'should change status sending activity to participant' do
    participation = FactoryGirl.create(:participation_with_participationable, participationable_type: :group)
    participation.change_status_to(Participation::ACCEPTED)
    assert_equal Participation::ACCEPTED, participation.status
  end

  test 'should change status sending activity to participationable owner' do
    participation = FactoryGirl.create(:participation_with_participationable, participationable_type: :group)
    participation.change_status_to(Participation::ACCEPTED)
    assert_equal Participation::ACCEPTED, participation.status
  end
end
