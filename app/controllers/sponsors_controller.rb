class SponsorsController < ApplicationController
  def index
    @sponsors = Sponsor.all
  end

  def new
    @sponsor = Sponsor.new
  end

  def create
    @sponsor = Sponsor.new(sponsor_params)
    return(redirect_to(sponsors_path)) if @sponsor.save
    render(:new)
  end

  def edit
    @sponsor = Sponsor.find(params[:id])
  end

  def update
    @sponsor = Sponsor.find(params[:id])
    return(redirect_to(sponsors_path)) if @sponsor.update(sponsor_params)
    render(:edit)
  end

  private

  def sponsor_params
    params.require(:sponsor).permit(:full_name)
  end
end
