class UsersController < ApplicationController
  def index
    @users = User.order('created_at DESC, id DESC')
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_url, notice: 'User was created and SMS notification was sent. Check server log for yourself!'
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :phone)
  end
end
