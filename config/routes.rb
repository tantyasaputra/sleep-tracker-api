Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get "up" => "health_check#up"

  # Defines the root path route ("/")
  resources :users, only: [ :index ] do
    collection do
      get "profiles", to: "users#profiles"
    end

    member do
      post "follow", to: "users#follow"
      post "unfollow", to: "users#unfollow"
    end
  end

  resources :sleep_logs, only: [ :index ] do
    collection do
      post :clock_in
      post :clock_out
      get :following
    end
  end
end
