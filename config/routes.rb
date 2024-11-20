Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "registrations"
  }
  root "users#index"

  resources :events

  resources :vendor_events

  resources :users




  # get "/add_event/:id", to: "vendor_events#show"

end
