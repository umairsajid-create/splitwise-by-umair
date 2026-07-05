# frozen_string_literal: true

module Admin
  class GroupsController < BaseController
    before_action :set_group, only: [:show, :archive, :restore]

    def index
      @groups = Group.includes(:group_members, :expenses)
                     .order(created_at: :desc)
      @groups = @groups.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
      @groups = @groups.where(is_active: params[:active] != "false")  if params[:active].present?
    end

    def show
      @members       = @group.members.order("group_members.joined_at DESC")
      @recent_expenses = @group.expenses.active_records.by_date.limit(10)
      @invitations   = @group.invitations.order(created_at: :desc).limit(10)
      @expense_total = @group.expenses.active_records.sum(:total_amount_cents) / 100.0
    end

    def archive
      @group.archive!
      redirect_to admin_groups_path, notice: "\"#{@group.name}\" archived."
    end

    def restore
      @group.update!(is_active: true)
      redirect_to admin_groups_path, notice: "\"#{@group.name}\" restored."
    end

    private

    def set_group
      @group = Group.find(params[:id])
    end
  end
end
