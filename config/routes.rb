Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "registrations"
  }
  root "users#index"

  resources :events, only: [:show, :index, :new, :create] do
    member do
      post 'add_event', to: 'vendor_events#add_event'
    end
  end

  resources :vendor_events do
    member do
      post "add_event", to: "vendor_events#add_event"
    end
  end

  resources :users, only: [:show]

  # get "/add_event/:id", to: "vendor_events#show"

end
