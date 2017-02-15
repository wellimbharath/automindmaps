Rails.application.routes.draw do
  resources :tree_views
  root to: 'home#index'
  get 'main/index'
  resources :main
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
