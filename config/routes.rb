Rails.application.routes.draw do
  devise_for :users
  root "users#index"

  resources :vendor_event
  resources :events
  resources :users

end
