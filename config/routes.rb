# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
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

  namespace :admin do
    root to: "analytics#index"
    get "analytics", to: "analytics#index"
    resources :users, only: [ :index ] do
      member do
        patch :block
        patch :unblock
      end
    end
  end

  mount Sidekiq::Web, at: "/sidekiq"

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
