Rails.application.routes.draw do
  scope('(:locale)') do
    resources(:lotteries, only: [:index, :new, :create, :edit, :update]) do
      resources(:prizes, only: [:index, :new, :create, :edit, :update])
      resources(:tables, only: [:index, :new, :create, :edit, :update])
      resources(:tickets, only: [:index, :new, :create, :edit, :update])
    end
    resources(:sellers, only: [:index, :new, :create, :edit, :update])
    resources(:guests, only: [:index, :new, :create, :edit, :update])
    resources(:sponsors, only: [:index, :new, :create, :edit, :update])
  end

  get '/:locale' => 'lotteries#index'
  root 'lotteries#index'
end
