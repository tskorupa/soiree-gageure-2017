Rails.application.routes.draw do
  resources(:lotteries, only: [:index, :new, :create, :edit, :update])

  root 'lotteries#index'
end
