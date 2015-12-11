class OverviewController < ApplicationController
  skip_before_action :require_login

  def welcome
  end

  def root
    if user_signed_in?
      redirect_to courses_path
    else
      # We use render here so the user will be redirected to root and not welcome after he logs in
      render 'welcome'
    end
  end
end
