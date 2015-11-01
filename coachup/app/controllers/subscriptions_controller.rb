class SubscriptionsController < ApplicationController

  def index

    @subscriptions = Subscription.all

  end

  def show

    @subscription = Subscription.find(params[:id])

  end

  def new

    @subscription = Subscription.new

  end

  def edit

    @subscription = Subscription.find(params[:id])

  end

  def create

    @subscription = Subscription.new(subscription_params)
    @subscription.user = current_user

    if @subscription.save
      redirect_to  @subscription
    else
      render 'new'
    end

  end

  def update

  end

  def destroy



  end

  def my_coaches_index
    @my_coaches = get_my_coaches
  end


  private

  def get_my_coaches

    @my_coaches = Array.new

    Subscription.find_each do |subscription|
      if subscription.user_id == current_user.id
        @sub_courses = Course.find(subscription.course_id)
        @my_coaches.push User.find(@sub_courses.coach_id)
      end
    end

    return @my_coaches
  end

  def subscription_params
    params.require(:subscription).permit(:course_id,:user_id)
  end

end
