class Ability
  include CanCan::Ability

  def initialize(user, request)

    #Define abilities for the passed in user here. For example:
    # if user
    #   user.roles.includes(:permissions).each do |role|
    #     role.permissions.each do |permission|
    #       can permission.action.to_sym, permission.subject_class.constantize
    #     end
    #   end
    # end
    #can [:login, :create, :check_email, :password_recovery, :update_password, :me], User
    if user

    end
    can :manage, [Calendar, CalendarItem, CalendarsGroup, Document, File, List, NotificationsPreference], user_id: user.id
    #can :manage, Calendar, user_id: user.id
    can :manage, User, id: user.id

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
