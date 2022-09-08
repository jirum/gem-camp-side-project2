Rails.application.routes.draw do

  constraints(ClientDomainConstraint.new) do
    devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }
    namespace :users do
      resource :profile, only: :show
      resources :addresses
      resources :winners, only: [:show, :update]
      resources :shares,  only: [:show, :update]
      scope :orders, as: :orders do
        put 'cancel/:id', as: :cancel, to: 'orders#cancel'
      end
    end
    resources :invites
    resources :lottery
    resources :winner_experience, only: [:show, :index]
    resources :shop, only: :index do
      post :new_order
    end
    root to: 'home#index'
  end

  constraints(AdminDomainConstraint.new) do
    namespace :admin, path: '' do
      root to: 'home#index'
      devise_for :users, controllers: { sessions: 'admin/sessions' }
      resources :user_list, only: :index
      resources :items, except: :show do
        put :start, :pause, :end, :cancel
      end
      resources :categories, except: :show
      resources :bets, only: :index do
        put :cancel
      end
      resources :winners, only: :index do
        put :submit, :pay, :ship, :deliver, :publish, :remove_publish
      end
      resources :offers, except: :show
      resources :orders, except: :show do
        put :submit, :pay ,:cancel
      end
    end
  end
end



