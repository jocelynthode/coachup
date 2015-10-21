class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  skip_before_action :require_login

  def index
    start = params[:start] || 0
    size = params[:size] || 20
    response = rest_request(:get, User.url + 'users/', accept: :json,
                            params: {start: start, size: size})
    @users = response[:users].map { |user| user[:username] }
  end

  def show
    response = rest_request(:get, User.url + 'users/' + params[:id],
                            accept: :json) 
   if bad_request?(response)
     redirect_to action: :index
     return
   end
   @user = response.reject { |k, v| k == :uri || v == '*' } 
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end

  private
  def set_user
    @username = session[:username]
    @password = session[:password]
  end

  def user_params
    params.require(:user).permit(:username, :password, :realname,
                                 :email, :publicvisible)
  end

  def rest_request(method, url, **args)
    begin
      response = RestClient::Request.execute(method: method, url: url,
                                             headers: args)
      JSON.parse(response, symbolize_names: true)
    rescue RestClient::Exception => exception
      exception
    end
  end

  def bad_request?(response)
    if response.is_a?(RestClient::Exception)
      true
    else
      false
    end
  end
end
