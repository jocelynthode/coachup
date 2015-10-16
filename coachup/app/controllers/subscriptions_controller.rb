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

    @subscription = Subscription.find(params[:id])
    if @subscription.update(subscription_params)
      redirect_to @subscription
    else
      render 'edit'
    end

  end

  def destroy

    @subscription = Subscription.find(params[:id])
    @subscription.destroy
    redirect_to subscriptions_path

  end

  def my_partnerships_index
    @subscriptions = get_my_partnerships
  end




  private

  def get_my_partnerships
    @my_subscriptions = Array.new

    Subscription.find_each do |subscription|

      if subscription.course_id == subscription.user_id
        @my_subscriptions.push subscription
      end
    end

    return @my_subscriptions
  end

    def subscription_params
      params.require(:subscription).permit(:course_id,:user_id)
    end

end
