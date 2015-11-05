class Course < ActiveRecord::Base
  belongs_to :coach, class_name: "User"
  delegate :username, :to => :coach
  has_many :subscriptions
  has_many :users, through: :subscriptions
  has_many :training_sessions
  belongs_to :location
  accepts_nested_attributes_for :location

  validates :title, presence: true
  validates :description, presence: true
  validates :coach_id, presence: true

  def self.url
    'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/'
  end
  # TODO rework th rescue part
  def self.get_all_sports
    begin
      response = RestClient::Request.execute(method: :get,
                                             url: self.url+'sports/',
                                             headers: { accept: :json })
      if response.code == 200
        answer = JSON.parse(response, symbolize_names: true)
        sports = []
        answer[:sports].each do |sport|
          sports << sport[:name]
        end
        sports
      else
        nil
      end
    rescue
      nil
    end
  end

  def apply(current_user)
    if self.coach.id == current_user.id
      ["You are the owner of this course!", :alert]
    elsif self.subscriptions.present?
      self.subscriptions.each do |sub|
        if sub.user == current_user
          #for some reason, the following line of code only works with a return
          return ["You are already subscribed!", :alert]
        end
      end
    elsif self.max_participants <= self.subscriptions.count
      ["Sorry! Maximum number of participants is already reached!", :alert]
    else
      self.subscriptions << Subscription.create(course: self, user: current_user)
      ["You are now subscribed to the course!", :notice]
    end
  end

  def leave(current_user)
    current_subscription = Subscription.find_by(course: self, user: current_user)
    if self.coach == current_user
      ["You are the coach - you can't leave ;)", :alert]
    elsif self.subscriptions.none? { |sub| sub.user == current_user}
      ["You are not subscribed to the course!", :alert]
    elsif current_subscription.present?
      current_subscription.destroy
      ["You are successfully unsubscribed from the course!", :notice]
    end
  end
end
