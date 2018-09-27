Rails.application.routes.draw do
  resources :users, except: [:show]
  post "/users/login", to: "users#login"
  post "/users/logout", to: "users#logout"
  post "/users/add_post", to: "users#add_post"

  root "users#index"
end
