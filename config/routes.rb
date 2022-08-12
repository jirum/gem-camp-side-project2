Rails.application.routes.draw do

  constraints(ClientDomainConstraint.new) do
    devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }
    namespace :users do
      resource :profile, only: :show
      resources :addresses
    end
    resources :invites
    root :to => 'home#index'
  end

  constraints(AdminDomainConstraint.new) do
    namespace :admin, path: '' do
      root :to => 'home#index'
      devise_for :users, controllers: { sessions: 'admin/sessions' }
    end
  end
end



