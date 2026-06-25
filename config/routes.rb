# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  # Devise authentication routes
  devise_for :users

  # Sidekiq Web UI (admin only — we'll add auth later)
  mount Sidekiq::Web, at: "/sidekiq"

  # Health check endpoint (required for deployment)
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA files
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Root route (we'll change this later)
  # root "home#index"
end
