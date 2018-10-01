Rails.application.routes.draw do
  resources :user, except: [:show]
  post "/user/login", to: "user#login"
  post "/user/add_post", to: "user#add_post"

  root "user#index"
end
