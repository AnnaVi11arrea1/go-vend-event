Rails.application.routes.draw do
  resources :comments
  draw(:pwa)
  draw(:custom)
  root "users#index"

  devise_for :users, controllers: { registrations: "registrations" }

  resources :follow_requests
  resources :events 
  resources :vendor_events do
    get "/calendar" => "calendar#show"
    collection do
      post "update_expenses_and_sales" => "vendor_events#update_expenses_and_sales"
    end
  end

  resources :users do
    resources :follow_requests
  end

end
