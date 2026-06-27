# frozen_string_literal: true

class ProfilesController < ApplicationController
  def show
    @user = current_user
  end

  def edit
    redirect_to edit_user_registration_path
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:username, :phone_number, :default_currency, :avatar)
  end
end
