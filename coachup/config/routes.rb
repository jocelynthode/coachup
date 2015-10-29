Rails.application.routes.draw do

  get 'login' => 'sessions#new', as: 'login'
  post 'login' => 'sessions#create'
  get 'logout' => 'sessions#destroy', as: 'logout'

  devise_for :users, controllers: { sessions: 'users/sessions' },
    path: "/", path_names: { sign_in: 'login', sign_up: 'register' }
  get 'overview/welcome'
  get 'overview/index'

  resources :users do
  end

=begin
  resources :my_partnerships do
  end
=end

  #resources :profiles, only: [:edit]
  get 'profiles/:id' => 'profiles#show', as: "user_profile"
  get 'profiles/' => 'profiles#index', as: "profiles"

  resources :locations do
  end


  get '/partnerships/', to: 'my_partnerships#index' , as: 'partnerships'
  get '/partnerships/:id/', to: 'my_partnerships#show' , as: 'partnership'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  authenticated :user do
    root to: 'overview#index', as: 'authenticated_root'
  end
  root 'overview#welcome'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  resources :courses do
    resources :locations
    collection do
      get 'my_courses_index'
      get 'courses_by_my_coaches_index'
      get 'courses_i_am_subscribed_to_index'
    end
    get 'apply', :action => :apply
    get 'leave', :action => :leave
    resources :training_sessions
  end

  resources :subscriptions do
    collection do
      get 'my_coaches_index'
    end
  end







  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
