Rails.application.routes.draw do
  resources :users, except: [:show] do
    collection do
      post :login
      post :logout
      post :add_post
      #post :delete_post
    end
  end
  #post "/users/login", to: "users#login"
  #post "/users/logout", to: "users#logout"
  #post "/users/add_post", to: "users#add_post"
  #post "/users/delete_post", to: "users#delete_post"

  root "users#index"
end
