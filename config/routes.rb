Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "registrations"
  }
  root "users#index"

  resources :vendor_event
  resources :events
  resources :users, only: [:show]

  get "/vendor_events", to: "vendor_events#index"

  get "/users/:id", to: "users#show"

  # get "/users/:id/edit", to: "reigstrations#edit", as: "edit_profile"

  # patch "/users/:id", to: "registrations#update"
  # patch "/events/:id", to: "events#update"
  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:
end
