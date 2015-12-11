class ApplicationController < ActionController::Base
  before_action :require_login
  helper_method :user_signed_in?, :current_user, :current_user_partnerships

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def require_login
    redirect_to login_path unless session[:username].present?
  end

  def current_user
    User.find_by username: session[:username] if user_signed_in?
  end

  def current_user_partnerships
    return unless session[:username].present?
    coach_user = CoachClient::User.new(coach_client, session[:username],
                                       password: session[:password])
    Partnership.new(coach_user)
  end

  def user_signed_in?
    session[:username].present?
  end

  def coach_client
    CoachClient::Client.new('http://diufvm31.unifr.ch:8090',
                            '/CyberCoachServer/resources/')
  end
end
