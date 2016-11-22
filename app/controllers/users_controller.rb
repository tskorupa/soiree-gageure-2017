class UsersController < ApplicationController
  def index
    @users = User.order('LOWER(email) ASC')
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    return(redirect_to(users_path)) if @user.save
    render(:new)
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    return(redirect_to(users_path)) if @user.update(user_params)
    render(:edit)
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
