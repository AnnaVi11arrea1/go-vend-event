Rails.application.routes.draw do
  devise_for :users
  root "events#index"

  resources :vendor_event
  resources :events


  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:
end
