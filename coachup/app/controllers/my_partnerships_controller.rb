class MyPartnershipsController < ApplicationController

  def index
    partnerships = current_user_partnerships.find()
    @partnerships = partnerships.map do |ps|
      ps.merge :user_id => User.find_by(username: ps[:user])
    end
  end

  def create
    partnership_action :create, params[:username]
  end

  def destroy
    partnership_action :destroy, params[:username]
  end

  private

    def partnership_action(action, username)
      message = {}
      begin
        current_user_partnerships.method(action).call username
      rescue RestClient::ExceptionWithResponse => e
        message[:alert] = e.response.body
      end

      begin
        redirect_to :back, flash: message
      rescue ActionController::RedirectBackError => e
        redirect_to partnerships_path, flash: message
      end
    end

end
