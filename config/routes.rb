Rails.application.routes.draw do
  resources(:lotteries, only: [:index, :new, :create, :edit, :update]) do
    resources(:prizes, only: [:index, :new, :create, :edit, :update])
    resources(:tables, only: [:index, :new, :create, :edit, :update])
  end
  resources(:sellers, only: [:index, :new, :create, :edit, :update])
  resources(:guests, only: [:index, :new, :create, :edit, :update])

  root 'lotteries#index'
end
