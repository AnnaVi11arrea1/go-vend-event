Rails.application.routes.draw do


  resources :vendor_events
  resources :events
  resources :users
  devise_for :user

  root "events#index"

  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:

  get "/" => "events#index"
  get "/users/:id" => "users#show"

  get "/events" => "events#index"
  get "/events/new" => "events#new"
  post "/events" => "events#create"

  get "/events/:id" => "events#show"
  get "/events/:id/edit" => "events#edit"
  patch "/events/:id" => "events#update"
  
  get "/vendor_events" => "vendor_events#index"
  
end
