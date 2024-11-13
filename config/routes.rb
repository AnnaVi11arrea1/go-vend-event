Rails.application.routes.draw do
  resources :vendor_events
  resources :events
  resources :users

  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:

  get "/" => "users#index"
  get "/users" => "users#show"
  get "/users/new" => "users#new"
  post "/users" => "users#create"
  get "/users/:id/edit" => "users#edit"
  patch "/users/:id" => "users#update"

  
end
