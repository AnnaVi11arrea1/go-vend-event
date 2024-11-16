Rails.application.routes.draw do
  devise_for :users
  root "users#index"

  resources :vendor_events
  resources :events
  resources :users

  get "/add_event/:id", to: "vendor_events#show"

end
