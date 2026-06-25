# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Guest users (not logged in) can't do anything
    return unless user.present?

    # ============================================
    # ALL USERS (simple, premium, admin)
    # ============================================
    can :read, User, id: user.id                    # View own profile
    can :update, User, id: user.id                  # Edit own profile

    # ============================================
    # PREMIUM + ADMIN users
    # ============================================
    if user.premium_or_admin?
      can :create, Group                             # Create groups
      can :view_charts, Group                        # View spending charts
      can :export, Group                             # Export CSV/Excel
      can :send_reminder, User                       # Send payment reminders
      can :search, Expense                           # Elasticsearch full-text search
      can :manage, DefaultSplit, user_id: user.id    # Save/load default splits
    end

    # ============================================
    # ADMIN only
    # ============================================
    if user.admin?
      can :manage, :all                              # Full access to everything
    end
  end
end
