Rails.application.routes.draw do
  devise_for :users

  constraints(ClientDomainConstraint.new) do
    root :to => 'home#index'
  end

  constraints(AdminDomainConstraint.new) do

  end
end


