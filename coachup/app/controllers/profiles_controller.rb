class ProfilesController < ApplicationController
  def show
    @user = User.find(params[:id])
    if @user.facebook_uid
      @facebook_url = 'https://www.facebook.com/' + @user.facebook_uid
    end
    @is_following = !current_user_partnerships.find(@user[:username]).empty?
  end

  def index
    @users = User.all
  end

  def edit

  end
end
