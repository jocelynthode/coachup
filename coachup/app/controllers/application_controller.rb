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
      User.find_by username: session[:username]
    else
      nil
    end
  end

  def user_signed_in?
    session[:username].present?
  end

  def authenticated_request(method, path, **args)
    raise "Error: not signed in" unless user_signed_in?
    url = User.url + path
    header = { accept: :json }
    header.merge!(args)
    begin
      response = RestClient::Request.execute(method: method, url: url,
                                             user: session[:username],
                                             password: session[:password],
                                             headers: header)
      JSON.parse(response, symbolize_names: true)
    rescue RestClient::Exception => exception
      exception
    end
  end

  def authenticated_put(path, payload, **args)
    raise "Error: not signed in" unless user_signed_in?
    url = User.url + path
    header = { accept: :json }
    header.merge!(args)
    begin
      response = RestClient::Request.execute(method: :put, url: url,
                                             user: session[:username],
                                             password: session[:password],
                                             payload: payload, headers: header)
      JSON.parse(response, symbolize_names: true)
    rescue RestClient::Exception => exception
      exception
    end
  end
end
