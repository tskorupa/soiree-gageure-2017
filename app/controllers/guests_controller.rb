class GuestsController < ApplicationController
  def index
    @guests = Guest.order('LOWER(full_name) ASC')

    respond_to do |format|
      format.html
      format.json { render(json: @guests.pluck(:full_name) ) }
    end
  end

  def new
    @guest = Guest.new
  end

  def create
    @guest = Guest.new(guest_params)
    return(redirect_to(guests_path)) if @guest.save
    render(:new)
  end

  def edit
    @guest = Guest.find(params[:id])
  end

  def update
    @guest = Guest.find(params[:id])
    return(redirect_to(guests_path)) if @guest.update(guest_params)
    render(:edit)
  end

  private

  def guest_params
    params.require(:guest).permit(:full_name)
  end
end
