Rails.application.routes.draw do
  devise_for :users
  root "users#index"

  resources :vendor_event
  resources :events
  resources :users

  get "/vendor_events", to: "vendor_events#index"

  get "/users/:id", to: "users#show", as: "user_profile"

  get "/users/:id/edit", to: "reigstrations#edit", as: "edit_profile"

  put "/users/:id", to: "registrations#update"
  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:
end
