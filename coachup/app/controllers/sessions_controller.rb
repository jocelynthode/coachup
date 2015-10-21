class SessionsController < ApplicationController
  skip_before_action :require_login

  def new
  end

  def create
    redirect_to users_path
  end

  def destroy
  end
end
