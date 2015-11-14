class Course < ActiveRecord::Base
  belongs_to :coach, class_name: "User"
  delegate :username, :to => :coach
  has_many :subscriptions
  has_many :users, through: :subscriptions
  belongs_to :location
  accepts_nested_attributes_for :location
  serialize :schedule, Hash

  validates_datetime :starts_at, on_or_after: lambda {DateTime.now}
  #TODO check for when ends_at doesn't exist
  validates_datetime :ends_at, after: :starts_at

  validates :starts_at, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :coach_id, presence: true

  Calendar = Google::Apis::CalendarV3

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
          ["You are already subscribed!", :alert]
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

  def schedule=(new_schedule)
    if new_schedule.nil?
      new_schedule = IceCube::Schedule.new( self.starts_at )
    end
    write_attribute(:schedule, RecurringSelect.dirty_hash_to_rule(new_schedule).to_hash)
  end

  def starts_at=(new_starts_at)
    write_attribute(:starts_at, DateTime.strptime(new_starts_at, '%d-%m-%Y %H:%M:%S'))
  end

  def ends_at=(new_ends_at)

      if new_ends_at != ""
        value = DateTime.strptime(new_ends_at, '%d-%m-%Y %H:%M:%S')
      else
        value = nil
      end
      write_attribute(:ends_at, value)
  end

  def retrieve_schedule
    if !self.schedule.empty?
      schedule = IceCube::Schedule.new(self.starts_at, end_time: self.ends_at)
      the_rule = RecurringSelect.dirty_hash_to_rule( self.schedule )
      if RecurringSelect.is_valid_rule?(the_rule)
        schedule.add_recurrence_rule( the_rule)
      end
      schedule
    end
  end

  def export_schedule(token)
    calendar = Calendar::CalendarService.new
    # dummy event
    event = Calendar::Event.new(summary: 'Hi', start: Calendar::EventDateTime.new(date_time: DateTime.current), end: Calendar::EventDateTime.new(date_time: DateTime.current + Rational(1, 24)))
    event = calendar.insert_event('primary', event, send_notifications: true,
                                  options: { authorization: token })
  end
end
