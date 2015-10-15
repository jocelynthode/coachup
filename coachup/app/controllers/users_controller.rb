class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!

  def index
    start = params[:start] || 0
    size = params[:size] || 20
    response = rest_request(:get, User.url + 'users/', accept: :json,
                            params: {start: start, size: size})
    @users = response['users'].map { |user| user['username'] }
  end

  def show
    response = RestClient.get(User.url + 'users/' + params[:id],
                              accept: :json)
    response = rest_request(:get, User.url + 'users/' + params[:id],
                            accept: :json) 
    @user = response.reject { |k, v| k == 'uri' || v == '*' } 
  end

  def new
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
    response = RestClient::Request.execute(method: method, url: url,
                                           headers: args)
    JSON.parse(response)
  end
end
