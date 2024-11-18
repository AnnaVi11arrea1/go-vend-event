Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "registrations"
  }
  root "users#index"

  resources :vendor_events
  resources :events
  resources :users, only: [:show]

  get "/add_event/:id", to: "vendor_events#show"

end
