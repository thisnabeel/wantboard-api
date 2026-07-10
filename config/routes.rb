# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  scope :api, defaults: { format: :json } do
    get "healthz", to: "health#show"

    post "auth/register", to: "auth#register"
    post "auth/login", to: "auth#login"
    get "auth/me", to: "auth#me"

    get "listings/my", to: "listings#my"
    resources :listings, only: %i[index show create update destroy] do
      resources :offers, only: %i[index create], controller: "listing_offers"
    end

    patch "offers/:id", to: "offers#update"
    get "offers/:offer_id/messages", to: "offer_messages#index"
    post "offers/:offer_id/messages", to: "offer_messages#create"

    get "conversations", to: "conversations#index"
    delete "conversations/:offer_id", to: "conversations#destroy"

    get "users/:id", to: "users#show"
  end
end
