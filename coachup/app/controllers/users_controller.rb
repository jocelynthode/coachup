class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  skip_before_action :require_login

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @is_following = !current_user_partnerships.find(@user[:username]).empty?
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
    # Note: This transaction may have a big impact on performance
    User.transaction do
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
          Cloudinary::Api.delete_resources(@user.avatar.file.public_id)
          redirect_to register_path, alert: msg
          raise ActiveRecord::Rollback
        else
          session[:username] = @user.username
          session[:password] = @user.password
          redirect_to root_path, notice: "Successfully created user #{@user.username}"
        end
      else
        render 'new'
      end
    end
  end

  def update
    # Note: This transaction may have a big impact on performance
    @user = current_user
    User.transaction do
      @user.username = session[:username]
      if @user.update(user_params)
        # Ugly fix
        @user.update_column :password, @user.new_password if @user.new_password.present?

        payload = { email: @user.email, realname: @user.realname }
        payload[:password] = @user.new_password if @user.new_password.present?
        payload_xml = payload.to_xml(root: :user, skip_instruct: true)
        response = authenticated_put("users/#{@user.username}", payload_xml,
                                     content_type: :xml)
        if bad_request?(response)
          flash[:alert] = "Could not save changes"
          render 'edit'
          raise ActiveRecord::Rollback
        else
          flash[:notice] = "Successfully updated profile"
          session[:password] = @user.new_password if @user.new_password.present?
          redirect_to user_path(current_user)
        end
      else
        render 'edit'
      end
    end
  end

  def destroy
  end

  def delete_avatar
    @user = current_user
    @user.remove_avatar = true
    @user.update_attribute(:avatar, nil)
    @user.reload

    redirect_to edit_user_path @user
  end

  def link_facebook
    # TODO: require_login (fix skip_before_action)
    auth = env['omniauth.auth']
    current_user.update_column :facebook_uid, auth.uid
    flash[:notice] = "Your profile is now linked to your facebook account"
    redirect_to user_path(current_user)
  end

  def unlink_facebook
    current_user.update_column :facebook_uid, nil
    flash[:notice] = "Your profile isn't link to any facebook account anymore"
    redirect_to user_path(current_user)
  end

  def upvote
    @user = User.find(params[:id])
    if @user != current_user
      @user.upvote_by current_user
    end
    redirect_to user_path(@user)
  end

  def downvote
    @user = User.find(params[:id])
    if @user != current_user
      @user.downvote_by current_user
    end
    redirect_to user_path(@user)
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
                                 :new_password, :new_password_confirmation, :avatar, :avatar_cache, :remove_avatar)
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
