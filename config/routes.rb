# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  # User Auth
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  # Admin Auth
  devise_for :admin_users, path: "admin", path_names: {
    sign_in:  "sign_in",
    sign_out: "sign_out"
  }, controllers: {
    sessions: "admin/sessions"
  }

  root "dashboard#index"

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

  get "activity", to: "activity#index", as: :activity

  get  "invitations/:token/accept",  to: "invitations#accept",  as: :accept_invitation
  post "invitations/:token/confirm", to: "invitations#confirm", as: :confirm_invitation

  resource :profile, only: [ :show, :edit, :update ]

  # Admin Panel
  namespace :admin do
    root to: "analytics#index"
    get "analytics", to: "analytics#index"

    # User management
    resources :users, only: [ :index, :show ] do
      member do
        patch :block
        patch :unblock
        patch :promote
        patch :demote
        post  :reset_password
      end
      resources :payments, only: [ :new, :create ], module: :users
    end

    # Groups
    resources :groups, only: [ :index, :show ] do
      member do
        patch :archive
        patch :restore
      end
    end

    # Expense
    resources :expenses, only: [ :index, :destroy ]

    # Invitations
    resources :invitations, only: [ :index ] do
      member do
        patch :expire
      end
    end

    # Unified activity log
    get "activity", to: "activity#index", as: :activity

    # Admin's own account settings
    resource :account, only: [ :show, :update ], controller: "account"
  end

  mount Sidekiq::Web, at: "/sidekiq"

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
