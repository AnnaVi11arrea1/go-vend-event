Rails.application.routes.draw do
  resources :comments
  draw(:pwa)
  draw(:custom)
  root "users#index"

  devise_for :users, controllers: { registrations: "registrations" }

  resources :follow_requests do
    member do
      patch :accept
      patch :reject
    end
  end

  resources :events do
    resources :comments, only: [:create, :edit, :update, :destroy]
  end

  resources :vendor_events do
    get "/calendar" => "calendar#show"
    collection do
      post "update_expenses_and_sales" => "vendor_events#update_expenses_and_sales"
    end
    resources :notes, only: [:create, :edit, :update, :destroy]
  end

  resources :users, only: [:show] do
    resources :follow_requests, only: [:new, :create]
  end

  get 'geocode_address', to: 'geocoding#geocode_address'

  get "external_data", to: 'external_data#index'

  get '/admin' => 'admin#index', as: :admin_root
  


end
