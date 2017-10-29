# frozen_string_literal: true
class SponsorsController < ApplicationController
  def index
    @sponsors_listing = SponsorListing.new

    respond_to do |format|
      format.html
      format.json { render(json: @sponsors_listing.to_a, each_serializer: SponsorRowSerializer) }
    end
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
