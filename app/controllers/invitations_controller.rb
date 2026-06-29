# frozen_string_literal: true

class InvitationsController < ApplicationController
  before_action :authenticate_user!, except: [ :accept, :confirm ]
  before_action :set_group, only: [ :new, :create, :created ]

  # GET /groups/:group_id/invitations/new
  def new
    @invitation = GroupInvitation.new
  end

  # POST /groups/:group_id/invitations
  def create
    unless @group.members.include?(current_user)
      redirect_to @group, alert: "Only members can invite others."
      return
    end

    @invitation = Invitations::SendService.new(
      group:      @group,
      invited_by: current_user,
      email:      params[:email]
    ).call

    redirect_to created_group_invitations_path(@group, invitation_id: @invitation.id),
                notice: "Invitation created. Copy the link below and send it to #{@invitation.email}."
  rescue Invitations::SendService::Error, ActiveRecord::RecordInvalid => e
    message = e.respond_to?(:record) ? e.record.errors.full_messages.to_sentence : e.message
    redirect_to new_group_invitation_path(@group), alert: message
  end

  # GET /groups/:group_id/invitations/created?invitation_id=:id
  def created
    @invitation = @group.invitations.find(params[:invitation_id])
    @invite_link = accept_invitation_url(token: @invitation.token)
  end

  # GET /invitations/:token/accept
  def accept
    @invitation = GroupInvitation.find_by!(token: params[:token])

    if @invitation.expired? || @invitation.accepted?
      redirect_to root_path, alert: "This invitation is invalid or has expired."
    elsif user_signed_in?
      render :accept
    else
      store_location_for(:user, request.fullpath)
      redirect_to new_user_session_path,
                  notice: "Please log in to accept the invitation. Don't have an account? Sign up first, then open the invite link again."
    end
  end

  # POST /invitations/:token/confirm
  def confirm
    authenticate_user!

    group = Invitations::AcceptService.new(
      token: params[:token],
      user:  current_user
    ).call

    redirect_to group_path(group), notice: "You have successfully joined #{group.name}!"
  rescue StandardError => e
    redirect_to root_path, alert: e.message
  end

  private

  def set_group
    @group = current_user.groups.find(params[:group_id])
  end
end
