Rails.application.routes.draw do
  devise_for :users,  controllers: { omniauth_callbacks: "users/omniauth_callbacks", session: 'users/sessions', registration: 'users/registrations' }

  devise_scope :user do
    get 'sign_up', to: 'devise/registrations#new', as:  :sign_up
    get 'sign_in', to: 'devise/sessions#new', as:  :sign_in
    get 'logout', to: 'devise/sessions#destroy', as:  :logout , method: :delete
  end
  resources :tree_views
  root to: 'home#index'
  resources :main
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
