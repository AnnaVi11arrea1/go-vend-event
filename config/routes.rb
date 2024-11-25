Rails.application.routes.draw do
  resources :follow_requests
  devise_for :users, controllers: {
    registrations: "registrations"
  }
  root "users#index"

  resources :events

  resources :vendor_events

  resources :users do
    member do
      post :follow
    end
  end




end
