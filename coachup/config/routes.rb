Rails.application.routes.draw do
  get 'login' => 'sessions#new', as: 'login'
  post 'login' => 'sessions#create'
  get 'logout' => 'sessions#destroy', as: 'logout'
  get 'register' => 'users#new', as: 'register'

  get 'overview/welcome'

  resources :users do
    resources :courses, only: [:index]
    resources :subscriptions do
      get 'coaches', action: 'coaches_index', on: :collection
      get 'coaches/courses', action: 'coaches_courses_index', on: :collection
    end

    get 'delete_avatar', :action => :delete_avatar
    member do
      put 'like', to: 'users#upvote'
      put 'dislike', to: 'users#downvote'
    end
  end

  resources :courses do
    post 'apply', :action => :apply
    post 'leave', :action => :leave
    get 'export', :action => :export
  end

  get '/auth/facebook/callback', to: 'users#link_facebook'
  delete '/auth/facebook', to: 'users#unlink_facebook'
  get '/auth/:provider/callback', to: 'sessions#token'
  get '/auth/failure', to: 'sessions#omniauth_failure'

  get '/partnerships/', to: 'my_partnerships#index', as: 'partnerships'
  post '/partnerships/:username', to: 'my_partnerships#create', as: 'partnership'
  delete '/partnerships/:username', to: 'my_partnerships#destroy'
  get '/partnerships/courses', to: 'my_partnerships#courses_index', as: 'partnerships_courses'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  root 'overview#root'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

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
