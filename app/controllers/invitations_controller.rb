# frozen_string_literal: true

class InvitationsController < ApplicationController
  before_action :authenticate_user!, except: [ :accept, :confirm ]

  # GET /groups/:group_id/invitations/new
  def new
    @group      = current_user.groups.find(params[:group_id])
    @invitation = GroupInvitation.new
  end

  # POST /groups/:group_id/invitations
  def create
    @group = current_user.groups.find(params[:group_id])
    # Can only invite if you are a member
    unless @group.members.include?(current_user)
      redirect_to @group, alert: "Only members can invite others."
      return
    end

    invitation = Invitations::SendService.new(
      group:      @group,
      invited_by: current_user,
      email:      params[:email]
    ).call

    # We will simulate the email being sent for now by flashing the link
    link = accept_invitation_url(token: invitation.token)
    redirect_to @group, notice: "Invitation created! (Since email is disabled, send them this link: #{link})"
  end

  # GET /invitations/:token/accept
  def accept
    @invitation = GroupInvitation.find_by!(token: params[:token])
    if @invitation.expired? || @invitation.accepted?
      redirect_to root_path, alert: "This invitation is invalid or has expired."
    elsif user_signed_in?
      # If logged in, show confirm screen
      render :accept
    else
      # If not logged in, force login/signup, then redirect back here
      store_location_for(:user, request.fullpath)
      redirect_to new_user_registration_path, notice: "Please sign up or log in to accept the invitation."
    end
  end

  # POST /invitations/:token/confirm
  def confirm
    authenticate_user!
    begin
      group = Invitations::AcceptService.new(
        token: params[:token],
        user:  current_user
      ).call
      redirect_to group_path(group), notice: "You have successfully joined #{group.name}!"
    rescue => e
      redirect_to root_path, alert: e.message
    end
  end
end
