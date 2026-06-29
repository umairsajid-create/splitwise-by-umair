# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  # ─────────────────────────────────────────
  # Authentication (Devise)
  # ─────────────────────────────────────────
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  # ─────────────────────────────────────────
  # Dashboard (root)
  # ─────────────────────────────────────────
  root "dashboard#index"

  # ─────────────────────────────────────────
  # Groups (stub — full implementation in Branch 4)
  # ─────────────────────────────────────────
  resources :groups do
    member do
      get :delete
    end
    resources :expenses, except: [ :index ]
    resources :settlements, only: [ :new, :create ]
    resources :invitations, only: [ :new, :create ] do
      collection do
        get :created
      end
    end
    resources :group_members, only: [ :destroy ]
    resource :membership, only: [ :show, :destroy ], controller: "group_memberships"
  end

  # ─────────────────────────────────────────
  # Activity feed stub (nav links to this)
  # ─────────────────────────────────────────
  get "activity", to: "activity#index", as: :activity

  # Invitations (token-based)
  get  "invitations/:token/accept",  to: "invitations#accept",  as: :accept_invitation
  post "invitations/:token/confirm", to: "invitations#confirm", as: :confirm_invitation

  # ─────────────────────────────────────────
  # Profile stub (nav links to this)
  # ─────────────────────────────────────────
  resource :profile, only: [ :show, :edit, :update ]

  # ─────────────────────────────────────────
  # Sidekiq Web UI
  # ─────────────────────────────────────────
  mount Sidekiq::Web, at: "/sidekiq"

  # ─────────────────────────────────────────
  # System routes
  # ─────────────────────────────────────────
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
