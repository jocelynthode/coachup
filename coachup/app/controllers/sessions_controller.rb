class SessionsController < ApplicationController
  skip_before_action :require_login

  def new
    redirect_to root_path, alert: "Already logged in" if current_user
  end

  def create
    username = params[:session][:username]
    password = params[:session][:password]
    if coach_client.authenticated?(username, password)
      session[:username] = username
      session[:password] = password
      unless User.find_by(username: username)
        new_user = User.new(username: username)
        coach_user = CoachClient::User.new(coach_client, username,
                                           password: password)
        coach_user.update
        new_user.password = password
        new_user.email = coach_user.email
        new_user.save(validate: false)
      end
      redirect_to root_path, notice: "Successfully logged in as #{username}"
    else
      flash[:alert] = "Invalid username or password"
      render 'new'
    end
  end

  def destroy
    session[:username] = nil
    session[:password] = nil
    redirect_to root_path, notice: "Successfully logged out"
  end

  def token
    auth = env['omniauth.auth']
    session[:token] = auth.credentials.token
    redirect_to session.delete(:return_to) || root_path
  end

  def omniauth_failure
    service_name = (params[:strategy] or '').capitalize
    flash[:alert] = "Error when connecting with #{service_name}: #{params[:message]}"
    redirect_to params[:origin] || root_path
  end
end
