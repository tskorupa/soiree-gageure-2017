# frozen_string_literal: true
class SellersController < ApplicationController
  def index
    @sellers_listing = SellersListing.new

    respond_to do |format|
      format.html
      format.json do
        render(
          json: @sellers_listing.to_a,
          each_serializer: SellerRowSerializer,
        )
      end
    end
  end

  def new
    @seller = Seller.new
  end

  def create
    @seller = Seller.new(seller_params)
    return(redirect_to(sellers_path)) if @seller.save
    render(:new)
  end

  def edit
    @seller = Seller.find(params[:id])
  end

  def update
    @seller = Seller.find(params[:id])
    return(redirect_to(sellers_path)) if @seller.update(seller_params)
    render(:edit)
  end

  private

  def seller_params
    params.require(:seller).permit(:full_name)
  end
end
