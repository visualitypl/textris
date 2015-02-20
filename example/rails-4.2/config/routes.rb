Rails.application.routes.draw do
  resources :users, :only => [:index, :show, :new, :create]

  root :to => 'users#new'
end
