Rails.application.routes.draw do
  resources(:lotteries, only: [:index, :new, :create, :edit, :update])
  resources(:sellers, only: [:index, :new, :create, :edit, :update])
  resources(:guests, only: [:index, :new, :create, :edit, :update])

  root 'lotteries#index'
end
