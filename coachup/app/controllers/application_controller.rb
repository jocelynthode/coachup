class ApplicationController < ActionController::Base
  before_action :require_login
  helper_method :user_signed_in?, :current_user

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def require_login
    redirect_to login_path unless session[:username].present?
  end

  def current_user
    if user_signed_in?
      session[:username]
    else
      nil
    end
  end

  def user_signed_in?
    session[:username].present?
  end
end
