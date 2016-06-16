require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::EventsParticipationsTest < ActionController::TestCase

  tests Api::V1::ParticipationsController
  include AuthenticatedUser

  test 'should create participation as family member for public event' do
    user = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: user)
    group = FactoryGirl.create(:group, owner: user)
    group.create_participation(user, @user)
    participant = FactoryGirl.create(:user)

    post :create, event_id: event.id, user_ids: [participant.id]
    assert_response :success
    assert event.participations.exists?(user: participant, status: Participation::PENDING)
  end

  test 'should not be able to create participation as family member for private event' do
    user = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: user, public: false)
    group = FactoryGirl.create(:group, owner: user)
    group.create_participation(user, @user)
    participant = FactoryGirl.create(:user)

    post :create, event_id: event.id, user_ids: [participant.id]
    assert_response :forbidden
  end

  test 'should create participation as event participant for public event' do
    event_owner = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: event_owner)
    FactoryGirl.create(:participation,
                       participationable: event,
                       user: @user,
                       sender: event_owner,
                       status: Participation::ACCEPTED)
    participant = FactoryGirl.create(:user)

    post :create, event_id: event.id, user_ids: [participant.id]
    assert_response :success
    assert event.participations.exists?(user: participant, status: Participation::PENDING)
  end

  test 'should create participation as event participant for private event' do
    event_owner = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: event_owner, public: false)
    FactoryGirl.create(:participation,
                       participationable: event,
                       user: @user,
                       sender: event_owner,
                       status: Participation::ACCEPTED)
    participant = FactoryGirl.create(:user)

    post :create, event_id: event.id, user_ids: [participant.id]
    assert_response :success
    assert event.participations.exists?(user: participant, status: Participation::PENDING)
  end

  test 'should be able to remove family member from public event' do
    event_owner = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: event_owner)
    group = FactoryGirl.create(:group, owner: event_owner)
    group.create_participation(event_owner, @user)
    participant = FactoryGirl.create(:user)
    participation = FactoryGirl.create(:participation,
                                       participationable: event,
                                       user: participant,
                                       sender: event_owner,
                                       status: Participation::ACCEPTED)
    #group.create_participation(user, participant)
    delete :destroy, event_id: event.id, id: participation.id
    assert_response :success
    assert_not Participation.exists?(id: participation.id)
  end

  test 'should not be able to remove family member from private event' do
    event_owner = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: event_owner, public: false)
    group = FactoryGirl.create(:group, owner: event_owner)
    group.create_participation(event_owner, @user)
    participant = FactoryGirl.create(:user)
    participation = FactoryGirl.create(:participation,
                                       participationable: event,
                                       user: participant,
                                       sender: event_owner,
                                       status: Participation::ACCEPTED)
    #group.create_participation(user, participant)
    delete :destroy, event_id: event.id, id: participation.id
    assert_response :forbidden
  end

  test 'should be able to remove participant from public event if I am participant' do
    event_owner = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: event_owner)
    FactoryGirl.create(:participation,
                       participationable: event,
                       user: @user,
                       sender: event_owner,
                       status: Participation::ACCEPTED)
    participant = FactoryGirl.create(:user)
    participation = FactoryGirl.create(:participation,
                                       participationable: event,
                                       user: participant,
                                       sender: event_owner,
                                       status: Participation::ACCEPTED)
    #group.create_participation(user, participant)
    delete :destroy, event_id: event.id, id: participation.id
    assert_response :success
    assert_not Participation.exists?(id: participation.id)
  end

  test 'should be able to remove participant from private event if I am participant' do
    event_owner = FactoryGirl.create(:user)
    event = FactoryGirl.create(:event, user: event_owner, public: false)
    FactoryGirl.create(:participation,
                       participationable: event,
                       user: @user,
                       sender: event_owner,
                       status: Participation::ACCEPTED)
    participant = FactoryGirl.create(:user)
    participation = FactoryGirl.create(:participation,
                                       participationable: event,
                                       user: participant,
                                       sender: event_owner,
                                       status: Participation::ACCEPTED)
    #group.create_participation(user, participant)
    delete :destroy, event_id: event.id, id: participation.id
    assert_response :success
    assert_not Participation.exists?(id: participation.id)
  end
end