Rails.application.routes.draw do
  with_options(defaults: { format: :json }) do |actions|
    actions.get('seller_names', to: 'sellers#index')
    actions.get('guest_names', to: 'guests#index')
    actions.get('sponsor_names', to: 'sponsors#index')
  end

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
