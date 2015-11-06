class MyPartnershipsController < ApplicationController

  def index
    partnerships = current_user_partnerships.find()
    @partnerships = partnerships.map do |ps|
      ps.merge :user_id => User.find_by(username: ps[:user])
    end
  end

  def create
    message = {}
    begin
      current_user_partnerships.create params[:username]
    rescue RestClient::ExceptionWithResponse => e
      message[:alert] = e.response.body
    end

    begin
      redirect_to :back, flash: message
    rescue ActionController::RedirectBackError => e
      redirect_to partnerships_path, flash: message
    end
  end

  def destroy

  end

end
