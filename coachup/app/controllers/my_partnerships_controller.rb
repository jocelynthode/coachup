class MyPartnershipsController < ApplicationController

  def index
    @partnerships = current_user_partnerships.find()
  end

  def create

  end

  def destroy

  end

end
