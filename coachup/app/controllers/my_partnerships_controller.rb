class MyPartnershipsController < ApplicationController

  def index
    partnerships = current_user_partnerships.find()
    @partnerships = partnerships.map do |ps|
      ps.merge :user_id => User.find_by(username: ps[:user])
    end
  end

  def create

  end

  def destroy

  end

end
