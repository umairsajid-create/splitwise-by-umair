# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Guest users can't do anything
    return unless user.present?

    # All authenticated users can read their own groups
    can :read,    Group, group_members: { user_id: user.id }
    can :update,  Group, group_members: { user_id: user.id, role: :admin }
    can :destroy, Group, group_members: { user_id: user.id, role: :admin }
    can :create,  Group

    # Premium users get additional capabilities
    if user.premium?
      can :view_charts,   Group
      can :export,        Group
      can :send_reminder, User
      can :search,        Expense
      can :manage,        DefaultSplit, user_id: user.id
    end
  end
end
