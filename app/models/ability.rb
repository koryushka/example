class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, :all, user_id: user.id
    can :manage, Participation, sender_id: user.id

    # can :create, Participation do |part|
    #   case part.participationable_type
    #     when Group.name
    #       user.family.present? && user.family.id == p.participationable_id
    #     else
    #       # replaces [can :manage, Participation, sender_id: user.id]
    #       # user.id == part.sender_id
    #       true
    #   end
    # end
    # can [:index, :index_recent, :destroy, :accept, :decline], Participation, sender_id: user.id
    can [:create_participation, :destroy_participation], Group do |group|
      family = user.family
      family.present? && family.id == group.id
    end

    can [:destroy_participation], Event do |event|
      event.participations.exists?(user_id: user.id)
    end

    can [:show], Event do |event|
      event.participations.exists?(user: user) || user.family.present? && user.family.members.exists?(id: event.user_id)
    end
    can [:update], Event do |event|
      user.family.present? && user.family.members.exists?(id: event.user_id) && event.public?
    end
    can :show, Group do |group|
      group.participations.exists?(user: user)
    end
    can [:leave, :update], Group do |group|
      group.participations.exists?(user: user) && group.user_id != user.id
    end
    can :destroy, Device do |device|
      user.devices.exists?(device_token: device.device_token)
    end
    can [:show, :update], List do |list|
      user.family.present? && user.family.members.exists?(id: list.user_id) && list.public?
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
