Rails.application.routes.draw do
  # Devise認証ルート
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # 認証後のダッシュボード（root）
  root 'dashboard#index'
  
  # ダッシュボードの別名
  get 'dashboard', to: 'dashboard#index', as: :dashboard


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
<<<<<<< HEAD:config/routes.rb
  get 'up' => 'rails/health#show', as: :rails_health_check

=======
  get "up" => "rails/health#show", as: :rails_health_check
  root to: "home#index"
  resources :users, only: [:index, :show, :edit, :update]
  resources :groups, only: [:new, :create, :edit, :update, :destroy]
>>>>>>> 5ab982a (membership作成した):calendar/config/routes.rb
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
