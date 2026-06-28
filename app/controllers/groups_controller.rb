# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [ :show, :edit, :update, :destroy ]

  # GET /groups
  def index
    @groups = current_user.groups.active.order(created_at: :desc)
  end

  # GET /groups/:id
  def show
    authorize! :read, @group
    @members  = @group.group_members.includes(:user)
    @expenses = @group.expenses.active
                      .where(record_type: :expense)
                      .order(expense_date: :desc)
                      .limit(20)
    @balances = Groups::BalanceService.new(@group).call
  end

  # GET /groups/new
  def new
    authorize! :create, Group
    @group = Group.new
  end

  # POST /groups
  def create
    authorize! :create, Group
    @group = Groups::CreateService.new(current_user, group_params).call

    if @group.persisted?
      redirect_to @group, notice: "Group \"#{@group.name}\" was created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /groups/:id/edit
  def edit
    authorize! :update, @group
  end

  # PATCH /groups/:id
  def update
    authorize! :update, @group
    if @group.update(group_params)
      redirect_to @group, notice: "Group updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /groups/:id
  def destroy
    authorize! :destroy, @group
    @group.archive!
    redirect_to groups_path, notice: "Group archived."
  end

  private

  def set_group
    @group = current_user.groups.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to groups_path, alert: "Group not found or access denied."
  end

  def group_params
    params.require(:group).permit(:name, :group_type, :avatar)
  end
end
