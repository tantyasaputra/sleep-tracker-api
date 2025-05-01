Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

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
