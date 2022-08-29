Rails.application.routes.draw do

  constraints(ClientDomainConstraint.new) do
    devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }
    namespace :users do
      resource :profile, only: :show
      resources :addresses
    end
    resources :invites
    resources :lottery
    root to: 'home#index'
  end

  constraints(AdminDomainConstraint.new) do
    namespace :admin, path: '' do
      root to: 'home#index'
      devise_for :users, controllers: { sessions: 'admin/sessions' }
      resources :user_list, only: :index
      resources :items, except: :show
      resources :categories, except: :show
      resources :bets, only: :index
    end
  end
end



