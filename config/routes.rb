Rails.application.routes.draw do


  resources :vendor_events
  resources :events
  resources :users
  devise_for :user

  root "events#index"

  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:

  get "/" => "events#index"


  
end
