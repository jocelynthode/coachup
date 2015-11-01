class Course < ActiveRecord::Base
  belongs_to :coach, class_name: "User"
  has_many :subscriptions
  has_many :users, through: :subscriptions
  has_many :training_sessions

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

=begin
  def self.get_courses_by_my_coaches
    begin
      my_courses = []
      response = RestClient::Request.execute(method: :get,
                                             url: self.url+'partnerships/',
                                             headers: { accept: :json })
      if response.code == 200
        answer = JSON.parse(response, symbolize_names: true)

        answer[:partnerships].each do |partnership|
          if partnership.user1 == current_user.username
            Course.find_each do |course|
              if course.coach.username == partnership.user2
                my_courses. << course
              end
            end
          elsif partnership.user2 == current_user.username
            Course.find_each do |course|
              if course.coach_id == partnership.user1
                my_courses << course
              end
            end
          end
        end

        my_courses
      else
        nil
      end
    rescue
      nil
    end
  end
=end

  def apply(current_user)
    if self.coach.id == current_user.id
      state = "You are the owner of this course!", :alert
    elsif self.subscriptions.present?
      self.subscriptions.each do |sub|
        if sub.user == current_user
          state = "You are already subscribed!", :alert
        end
      end
    elsif self.max_participants <= self.subscriptions.count
      state = "Sorry! Maximum number of participants is already reached!", :alert
    else
      self.subscriptions << Subscription.create(:course => self, :user => current_user)
      state = "You are now subscribed to the course!", :notice
    end
    state
  end

  def leave(current_user)
    current_subscription = Subscription.find_by(:course => self, :user => current_user)
    if self.coach == current_user
      state = "You are the coach - you can't leave ;)", :alert
    elsif !self.subscriptions.any? { |sub| sub.user == current_user}
      state = "You are not subscribed to the course!", :alert
    elsif current_subscription.present?
      current_subscription.destroy
      state = "You are successfully unsubscribed from the course!", :notice
    end
    state
  end
end
