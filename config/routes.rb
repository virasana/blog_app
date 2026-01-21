Rails.application.routes.draw do
  # Posts resource
  resources :posts do
    post :enqueue_notifier, on: :member
  end

  # Sidekiq Web UI
  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA routes (commented out for now)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root path
  root "posts#index"
end
