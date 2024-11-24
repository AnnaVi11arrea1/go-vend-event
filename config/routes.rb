Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "registrations"
  }
  root "users#index"

  resources :events

  resources :vendor_events

  resources :users

  resources :spreadsheets, only: [:index] do
    collection do
      post 'update'
    end
  end


end
