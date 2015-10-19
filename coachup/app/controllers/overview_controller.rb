class OverviewController < ApplicationController

  # I assume we will have the :authenticate_user! filter applied in application_controller
  # TODO: adapt next line if we don't use :authenticate_user! application-wide
  skip_before_action :authenticate_user!, only: [:welcome]

  def index
  end

  def welcome
  end

end
