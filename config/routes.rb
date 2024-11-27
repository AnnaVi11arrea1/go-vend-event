Rails.application.routes.draw do
  root "users#index"

  devise_for :users

  resources :follow_requests
  resources :events 
  resources :vendor_events do
    get "/calendar" => "calendar#show"
  end
  resources :users



  get ":username/feed" => "users#feed", as: :feed
  get ":username/followers" => "users#followers", as: :followers
  get ":username/following" => "users#following", as: :following
  get ":username/discover" => "users#discover", as: :discover


  get "/logout" => "users#logout"
  get "/privacy_policy" => "users#privacy", as: :privacy_policy
end
