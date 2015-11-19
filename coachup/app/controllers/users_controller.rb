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
    response = authenticated_request(:get, "users/#{session[:username]}")
    unless bad_request?(response)
      @user = current_user
      @user.realname = response[:realname]
      @user.publicvisible = response[:publicvisible]
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      payload = { email: @user.email, password: @user.password,
                  realname: @user.realname, publicvisible: "2" }
      payload_xml = payload.to_xml(root: :user, skip_instruct: true)
      url = User.url + 'users/' + @user.username
      response = rest_put(url, payload_xml, accept: :json, content_type: :xml)
      if bad_request?(response)
        msg = if exception_code(response) == 401
                "User #{@user.username} already exists"
              else
                "Something went wrong"
              end
        redirect_to register_path, alert: msg
      else
        session[:username] = @user.username
        session[:password] = @user.password
        redirect_to root_path, notice: "Successfully created user #{@user.username}"
      end
    else
      render 'new'
    end
  end

  def update
    @user = current_user
    @user.username = session[:username]
    if @user.update(user_params)
      payload = { email: @user.email, realname: @user.realname }
      payload[:password] = @user.new_password if @user.new_password.present?
      payload_xml = payload.to_xml(root: :user, skip_instruct: true)
      response = authenticated_put("users/#{@user.username}", payload_xml,
                                   content_type: :xml)
      if bad_request?(response)
        flash[:alert] = "Could not save changes"
      else
        flash[:notice] = "Successfully updated profile"
        session[:password] = @user.new_password if @user.new_password.present?
      end
      redirect_to user_profile_path(current_user.id)
    else
      render 'edit'
    end
  end

  def destroy
  end

  def delete_avatar
    @user = current_user
    @user.remove_avatar = true
    @user.save
    @user.reload

    redirect_to edit_profile_path
  end

  private
  def set_user
    @username = session[:username]
    @password = session[:password]
  end

  def user_params
    params.require(:user).permit(:username, :password, :realname, :email,
                                 :publicvisible, :password_confirmation,
                                 :address, :country, :phone, :date_of_birth, :education, :bio, :aboutme,
                                 :new_password, :new_password_confirmation, :avatar, :avatar_cache)
  end

  def rest_put(url, payload, **args)
    begin
      response = RestClient::Request.execute(method: :put, url: url,
                                             payload: payload, headers: args)
      JSON.parse(response, symbolize_names: true)
    rescue RestClient::Exception => exception
      exception
    end
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

  def exception_code(exception)
    exception.response.code
  end
end
