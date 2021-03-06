class Ability
  include CanCan::Ability

  def initialize(user)
    family = user.family

    can :manage, :all, user_id: user.id
    can :manage, Participation, sender_id: user.id

    can [:create_participation, :destroy_participation], Group do |group|
      family.present? && family.id == group.id
    end
    can :show, Group do |group|
      group.participations.exists?(user: user)
    end
    can [:leave, :update], Group do |group|
      group.participations.exists?(user: user) && group.user_id != user.id
    end

    can :create_participation, Event do |event|
      event.user_id == user.id ||
          family.present? && family.members.exists?(id: user.id) && event.public? ||
          event.participations.exists?(user: user, status: Participation::ACCEPTED)
    end
    can :destroy_participation, Event do |event|
      event.participations.exists?(user_id: user.id) ||
          family.present? && family.members.exists?(id: user.id) && event.public?
    end
    can :show, Event do |event|
      event.participations.exists?(user: user) || user.family.present? && user.family.members.exists?(id: event.user_id)
    end
    can :update, Event do |event|
      user.family.present? && user.family.members.exists?(id: event.user_id) && event.public?
    end
    can :event_status_update, Event do |event|
      event.user_id == user.id
    end
    can [:add_list, :remove_list], Event do |event|
      event.user_id == user.id ||
          family.present? && family.members.exists?(id: event.user_id) && event.public? ||
          event.participations.exists?(user_id: user.id, status: Participation::ACCEPTED)
    end
    can :view_private, Event do |event|
      event.public? || user.id == event.user_id ||
          event.participations.exists?(user_id: user.id, status: Participation::ACCEPTED)
    end

    can :destroy, Device do |device|
      user.devices.exists?(device_token: device.device_token)
    end

    can [:show, :update], List do |list|
      user.family.present? && user.family.members.exists?(id: list.user_id) && list.public?
    end
    cannot :attach_private_list, List do |list|
      not list.public?
    end

    #Define abilities for the passed in user here. For example:
    # if user
    #   user.roles.includes(:permissions).each do |role|
    #     role.permissions.each do |permission|
    #       can permission.action.to_sym, permission.subject_class.constantize
    #     end
    #   end
    # end
    #can [:login, :create, :check_email, :password_recovery, :update_password, :me], User
    # if user
    #   can :manage, [Calendar, CalendarItem, CalendarsGroup, Document, File, List, NotificationsPreference] do |subject|
    #     subject.user_id == user.id
    #   end
    #   can :read, [Calendar, CalendarItem, CalendarsGroup, Document, File, List, NotificationsPreference] do |subject|
    #     user.sharing_permissions
    #         .exists?(subject_class: subject.class.name.downcase, subject_id: subject.id)
    #   end
    #   #can :manage, Calendar, user_id: user.id
    #   can :manage, User, id: user.id
    # end


    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
