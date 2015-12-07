class MyPartnershipsController < ApplicationController

  def index
    partnerships = current_user_partnerships.find(coach_client)
    partnerships.select! { |p| p.user1_confirmed }
    @partnerships = []
    partnerships.each do |p|
      @partnerships.unshift({ user_id: User.find_by(username: p.user2.username),
                              partnership: p })
    end
  end

  def create
    partnership_action :create, params[:username]
  end

  def destroy
    partnership_action :destroy, params[:username]
  end

  def courses_index
    @courses = []
    coach_user = CoachClient::User.new(coach_client, current_user.username,
                                         password: session[:password])
    begin
      coach_user.update
      partnerships = coach_user.partnerships
    rescue CoachClient::Exception
      return
    end

    partnerships.each do |partnership|
      user = User.find_by(username: partnership.user2.username)
      user_id = user.id if user
      Course.find_each do |course|
        @courses << course if course.coach_id == user_id
      end
    end
  end

  private

    def partnership_action(action, username)
      message = {}
      begin
        current_user_partnerships.method(action).call(coach_client, username)
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

