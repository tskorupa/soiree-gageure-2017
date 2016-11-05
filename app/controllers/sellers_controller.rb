class SellersController < ApplicationController
  def index
    @sellers = Seller.order('LOWER(full_name) ASC')
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
