  require "sidekiq/web" # require the web UI

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  mount Sidekiq::Web => "/sidekiq"

  scope defaults: { format: :json } do
    resources :messages, only: [:create]
    resources :rockets, only: [:show, :index] do
      resources :rocket_messages, only: [:index]
    end
  end
end
