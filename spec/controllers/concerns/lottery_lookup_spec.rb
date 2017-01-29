require 'rails_helper'

class LotteryLookupTestController < ActionController::Base
  include LotteryLookup
end

RSpec.describe(LotteryLookupTestController, type: :controller) do
  controller do
    def index
      render nothing: true
    end
  end

  let(:lottery) do
    Lottery.create!(event_date: Date.today)
  end

  it('assigns @lottery when the params contain :lottery_id and it corresponds to an existing lottery') do
    get :index, params: { lottery_id: lottery.id }
    expect(assigns[:lottery]).to eq(lottery)
  end

  it('raises an exception when the params contain :lottery_id that corresponds to no existing lottry') do
    expect do
      get :index, params: { lottery_id: 1 }
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  it('raises an exception when the params do not contain :lottery_id') do
    expect do
      get :index
    end.to raise_error(ActiveRecord::RecordNotFound)
  end
end
