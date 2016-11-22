Rails.application.routes.draw do
  scope(':locale') do
    devise_for(:users)

    with_options(
      only: %i(index new create edit update),
    ) do |actions|
      actions.resources(:lotteries) do
        actions.resources(:prizes)
        actions.resources(:tables)
        actions.resources(:tickets)
      end
      actions.resources(:sellers)
      actions.resources(:guests)
      actions.resources(:sponsors)
      actions.resources(:users)
    end

    root 'lotteries#index'
  end
end
