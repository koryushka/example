require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::ParticipationsControllerTest < ActionController::TestCase
  include AuthenticatedUser
  resources_types = %w(event list group)

  test 'should index participations for resources' do
    users = FactoryGirl.create_list(:user, 5)

    resources_types.each do |resource_type|
      resource = FactoryGirl.create(resource_type, user: @user)
      users.each do |user|
        Participation.create(user: user,
                             participationable: resource,
                             sender: @user)
      end

      get :index, "#{resource_type}_id": resource.id
      assert_response :success
      assert_not_nil json_response
      assert json_response.size > 0
    end
  end

  test 'should invite participants to resources' do
    emails = Array.new(5) { Faker::Internet.email }
    existing_user = FactoryGirl.create(:user)
    emails << existing_user.email

    resources_types.each do |resource_type|
      resource = FactoryGirl.create(resource_type, user: @user)
      post :create, "#{resource_type}_id": resource.id, emails: emails
      assert_response :success
    end

    users = FactoryGirl.create_list(:user, 5)
    resources_types.each do |resource_type|
      resource = FactoryGirl.create(resource_type, user: @user)
      post :create, "#{resource_type}_id": resource.id, user_ids: users.map { |user| user.id }
      assert_response :success
    end
  end

  test 'should remove participant from resources' do
    user = FactoryGirl.create(:user)

    resources_types.each do |resource_type|
      resource = FactoryGirl.create(resource_type, user: @user)
      participation = Participation.create(user: user,
                                           participationable: resource,
                                           sender: @user)

      delete :destroy, "#{resource_type}_id": resource.id, id: participation.id
      assert_response :success

      resource.reload
      assert_equal 0, resource.participations.size
    end
  end

  test 'should show recent participations sent by user' do
    users_count = 5
    users = FactoryGirl.create_list(:user, users_count)

    resources_types.each do |resource_type|
      resource = FactoryGirl.create(resource_type, user: @user)
      users.each do |user|
        Participation.create(user: user,
                             participationable: resource,
                             sender: @user)
      end

      get :index_recent
      assert_response :success
      assert_not_nil json_response
      assert_equal users_count, json_response.size
    end
  end

  test 'should accept participation' do
    participation = FactoryGirl.create(:participation_with_participationable,
                                       participationable_type: :group,
                                       user: @user)
    post :accept, id: participation.id
    assert_response :success

    participation.reload
    assert participation.accepted?
    # assert participation.sender.activities.exists?(notificationable_type: Participation.name,
    #                                                notificationable_id: participation.id,
    #                                                activity_type: Participation::ACCEPTED)
  end

  test 'should decline participation' do
    participation = FactoryGirl.create(:participation_with_participationable,
                                       participationable_type: :group,
                                       user: @user)
    post :decline, id: participation.id
    assert_response :success

    participation.reload
    assert participation.declined?
    # assert participation.sender.activities.exists?(notificationable_type: Participation.name,
    #                                                notificationable_id: participation.id,
    #                                                activity_type: Participation::DECLINED)
  end

  test 'should fail accepting of already accepted participation' do
    participation = FactoryGirl.create(:participation_with_participationable,
                                       participationable_type: :group,
                                       user: @user,
                                       status: Participation::ACCEPTED)
    post :accept, id: participation.id
    assert_response :not_acceptable
  end

  test 'should fail declining of already declined participation' do
    participation = FactoryGirl.create(:participation_with_participationable,
                                       participationable_type: :group,
                                       user: @user,
                                       status: Participation::DECLINED)
    post :decline, id: participation.id
    assert_response :not_acceptable
  end

end
