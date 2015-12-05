class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  skip_before_action :require_login

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    if @user.facebook_uid
      @facebook_url = 'https://www.facebook.com/' + @user.facebook_uid
    end
    @is_following = !current_user_partnerships.find(@user[:username]).empty?
  end

  def new
    @user = User.new
  end

  def edit
    coach_user = CoachClient::User.new(coach_client, session[:username],
                                       password: session[:password])
    coach_user.update
    @user = current_user
    @user.realname = coach_user.realname
    @user.publicvisible = coach_user.publicvisible
  end

  def create
    # Note: This transaction may have a big impact on performance
    User.transaction do
      @user = User.new(user_params)
      if @user.save
        coach_user = CoachClient::User.new(coach_client, @user.username,
                                           password: @user.password,
                                           email: @user.email,
                                           realname: @user.realname,
                                           publicvisible: 2)
        begin
          coach_user.save
        rescue CoachClient::Exception => e
          unless @user.avatar.present?
            Cloudinary::Api.delete_resources(@user.avatar.file.public_id)
          end
          msg = if e.is_a?(CoachClient::Unauthorized)
                  "User #{@user.username} already exists"
                else
                  "Could not create new user"
                end
          redirect_to register_path, alert: msg
          raise ActiveRecord::Rollback
        end
        session[:username] = @user.username
        session[:password] = @user.password
        redirect_to root_path, notice: "Successfully created user #{@user.username}"
      else
        render 'new'
      end
    end
  end

  def update
    # Note: This transaction may have a big impact on performance
    @user = current_user
    User.transaction do
      if @user.update(user_params)
        coach_user = CoachClient::User.new(coach_client, session[:username],
                                           password: session[:password],
                                           email: @user.email,
                                           realname: @user.realname)
        if @user.new_password.present?
          coach_user.newpassword = @user.new_password
          # Ugly fix
          @user.update_column :password, @user.new_password
        end

        begin
          coach_user.save
        rescue CoachClient::Exception
          flash[:alert] = "Could not save changes"
          render 'edit'
          raise ActiveRecord::Rollback
        end
        flash[:notice] = "Successfully updated profile"
        session[:password] = @user.new_password if @user.new_password.present?
        redirect_to user_path(current_user)
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
end

