class MyPartnershipsController < ApplicationController
  def index
    partnerships = current_user_partnerships.find
    @partners = []
    partnerships.each do |p|
      user = User.find_by(username: p.user2.username)
      @partners.unshift(user) unless user.nil?
    end
  end

  def create
    partnership_action :create, params[:username]
  end

  def destroy
    partnership_action :destroy, params[:username]
  end

  def courses_index
    begin
      partnerships = current_user_partnerships.find
    rescue CoachClient::Exception
      return
    end

    usernames = partnerships.map { |ps| ps.user2.username }
    users = User.where(username: usernames)
    @courses = Course.where(coach: users)
  end

  private

  def partnership_action(action, username)
    message = {}
    begin
      current_user_partnerships.method(action).call(username)
    rescue CoachClient::Exception
      message[:alert] = "Partnership action failed"
    end

    begin
      redirect_to :back, flash: message
    rescue ActionController::RedirectBackError
      redirect_to partnerships_path, flash: message
    end
  end
end
