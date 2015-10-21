class ApplicationController < ActionController::Base
  before_action :require_login

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def require_login
    redirect_to login_path unless session[:username].present?
  end

  def current_user
    if session[:username].present?
      session[:username]
    else
      nil
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :name, :last_name, :address, :country, :phone, :date_of_birth, :education, :trophies, :bio, :aboutme, :personal_records,  :password, :password_confirmation, :current_password) }
  end
end
