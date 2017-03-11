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
      resources(:lotteries, only: %i(index new create edit show update)) do
        actions.resources(:prizes)
        actions.resources(:tickets)
        resources(:tables, only: %i(index new create edit show update))
        resources(:ticket_registrations, only: %i(index edit update))
        resources(:ticket_impressions, only: %i(index show))
        resources(:ticket_drop_offs, only: %i(index update))
        resources(:ticket_draws, only: %i(index update))
        resources(:drawn_tickets, only: %i(index update))
        resources(:results, only: %i(index))
      end
      actions.resources(:sellers)
      actions.resources(:guests)
      actions.resources(:sponsors)
      actions.resources(:users)
    end
    resources(:lock_lotteries, only: :update)

    root 'lotteries#index'
  end

  mount(ActionCable.server => '/cable')
end
