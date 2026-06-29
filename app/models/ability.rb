# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Guest users (not logged in) can't do anything
    return unless user.present?

    # ALL USERS — own groups they are members of

    can :read,    Group, group_members: { user_id: user.id }
    can :update,  Group, group_members: { user_id: user.id, role: :admin }
    can :destroy, Group, group_members: { user_id: user.id, role: :admin }
    can :create,  Group

    # PREMIUM + ADMIN users only
    if user.premium_or_admin?
      can :view_charts,   Group
      can :export,        Group
      can :send_reminder, User
      can :search,        Expense
      can :manage,        DefaultSplit, user_id: user.id
    end


    # ADMIN only
    if user.admin?
      can :manage, :all
    end
  end
end
