
module Groups
  class CreateService
    def initialize(user, params)
      @user   = user
      @params = params
    end

    def call
      group = Group.new(@params.merge(creator: @user))

      Group.transaction do
        if group.save
          # Creator is automatically made an admin member
          group.group_members.create!(
            user:       @user,
            role:       :admin,
            joined_at:  Time.current
          )
        end
      end

      group  # Return the group (check group.persisted? in controller)
    end
  end
end
