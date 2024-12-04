# https://github.com/heartcombo/devise/issues/5644
Devise.setup do |config|
  config.secret_key = ENV["DEVISE_SECRET_KEY"]
end
