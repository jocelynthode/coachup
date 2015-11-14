class SessionsController < ApplicationController
  skip_before_action :require_login

  def new
    redirect_to root_path, alert: "Already logged in" if current_user
  end

  def create
    username = params[:session][:username]
    password = params[:session][:password]
    user = User.authenticate(username, password)
    if user
      session[:username] = username
      session[:password] = password
      unless User.find_by username: username
        new_user = User.new(username: username)
        response = authenticated_request(:get, "users/#{username}")
        new_user.email = response[:email]
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
end
