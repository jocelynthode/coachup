class SubscriptionsController < ApplicationController
  def index
    @user = User.find params[:user_id]
    @courses = @user.courses
  end

  def create
    @subscription = Subscription.new(subscription_params)
    @subscription.user = current_user

    if @subscription.save
      redirect_to @subscription
    else
      render 'new'
    end
  end

  def destroy
  end

  def coaches_index
    @user = User.find params[:user_id]
    @coaches = get_coaches @user
  end

  def coaches_courses_index
    coaches_index
    @courses = Course.where(coach: @coaches)
  end

  private

  def get_coaches(user)
    coaches = []
    user.subscriptions.find_each do |subscription|
      unless coaches.include?(subscription.course.coach)
        coaches << subscription.course.coach
      end
    end
    coaches
  end

  def subscription_params
    params.require(:subscription).permit(:course_id, :user_id)
  end
end
