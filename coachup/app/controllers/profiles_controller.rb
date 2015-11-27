class ProfilesController < ApplicationController
  def show
    @user = User.find(params[:id])
    @is_following = !current_user_partnerships.find(@user[:username]).empty?
  end

  def index
    @users = User.all
  end

end
