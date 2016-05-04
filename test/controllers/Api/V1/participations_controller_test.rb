require File.expand_path('../../../../test_helper', __FILE__)

class Api::V1::ParticipationsControllerTest < ActionController::TestCase
  include AuthenticatedUser
  resources_types = %w(event list)

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

end
