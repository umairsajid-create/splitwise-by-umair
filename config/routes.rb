# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  # Authentication (Devise)
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  root "dashboard#index"

  resources :groups do
    resources :expenses, except: [ :index ]
    resources :settlements, only: [ :new, :create ]
      resources :invitations, only: [ :new, :create ]
    resources :group_members, only: [ :destroy ]
  end

  # Activity feed stub (nav links to this)
  get "activity", to: "activity#index", as: :activity

  get  "invitations/:token/accept",  to: "invitations#accept",  as: :accept_invitation
  post "invitations/:token/confirm", to: "invitations#confirm", as: :confirm_invitation

  resource :profile, only: [ :show, :edit, :update ]
  mount Sidekiq::Web, at: "/sidekiq"


  # System routes
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
