get ":username/feed" => "users#feed", as: :feed
get ":username/followers" => "users#followers", as: :followers
get ":username/following" => "users#following", as: :following
get ":username/discover" => "users#discover", as: :discover
get "/charts" => "charts#index"
get "/logout" => "users#logout"
get "/privacy_policy" => "users#privacy", as: :privacy_policy
