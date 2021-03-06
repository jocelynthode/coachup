class Course < ActiveRecord::Base
  belongs_to :coach, class_name: "User"
  delegate :username, :to => :coach
  has_many :subscriptions, dependent: :delete_all
  has_many :users, through: :subscriptions
  belongs_to :location
  accepts_nested_attributes_for :location, reject_if: :no_location
  serialize :schedule, Hash

  scope :desc, -> { order('courses.created_at DESC') }

  validates_datetime :starts_at, on_or_after: -> { DateTime.current }
  validates_datetime :ends_at, after: :starts_at

  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :coach_id, presence: true
  validates :location, presence: true
  validates :price, presence: true

  Calendar = Google::Apis::CalendarV3

  def apply(current_user)
    # Use a transaction because the database allow multiple subscriptions
    # for the same user/course !
    # TODO: fix this in the DB schema instead ?
    Subscription.transaction do
      if coach.id == current_user.id
        return ["You are the owner of this course!", :alert]
      end

      if max_participants <= subscriptions.size
        return ["Sorry! Maximum number of participants is already reached!", :alert]
      end

      if subscriptions.exists?(user: current_user)
        return ["You are already subscribed!", :alert]
      end

      subscriptions.create(user: current_user)
      ["You are now subscribed to the course!", :notice]
    end
  end

  def leave(current_user)
    current_subscription = Subscription.find_by(course: self, user: current_user)
    if coach == current_user
      ["You are the coach - you can't leave ;)", :alert]
    elsif subscriptions.none? { |sub| sub.user == current_user }
      ["You are not subscribed to the course!", :alert]
    elsif current_subscription.present?
      current_subscription.destroy
      ["You are successfully unsubscribed from the course!", :notice]
    end
  end

  def schedule=(new_schedule)
    if new_schedule != "null"
      write_attribute(:schedule, RecurringSelect.dirty_hash_to_rule(new_schedule).to_hash)
    else
      write_attribute(:schedule, nil)
    end
  end

  def starts_at=(new_starts_at)
    if new_starts_at != ''
      value = DateTime.strptime(new_starts_at, '%d-%m-%Y %H:%M:%S')
    else
      value = nil
    end
    write_attribute(:starts_at, value)
  end

  def duration=(new_duration)
    write_attribute(:duration, new_duration)
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
    schedule = IceCube::Schedule.new(starts_at, end_time: ends_at)
    unless self.schedule.empty?
      the_rule = RecurringSelect.dirty_hash_to_rule(self.schedule)
      if RecurringSelect.is_valid_rule?(the_rule)
        schedule.add_recurrence_rule(the_rule.until(ends_at))
      end
    end
    schedule
  end

  def export_schedule(token)
    calendar = Calendar::CalendarService.new
    schedule = retrieve_schedule
    schedule.occurrences(ends_at).each do |sess|
      dur = duration.seconds_since_midnight
      start_time = Calendar::EventDateTime.new(date_time: sess.start_time.to_datetime)
      end_time = Calendar::EventDateTime.new(date_time: sess.start_time.to_datetime + dur.seconds)
      location_string = "#{location.latitude},#{location.longitude}"
      id = title + description + location_string + sess.start_time.strftime("%Y-%m-%dT%l:%M:%S%z") + sess.end_time.strftime("%Y-%m-%dT%l:%M:%S%z") + dur.to_s
      base32_id = id.each_byte.map { |b| b.to_s(32) }.join
      event = Calendar::Event.new(id: base32_id, summary: title,
                                  description: description,
                                  location: location_string,
                                  start: start_time, end: end_time)
      begin
        calendar.insert_event('primary', event, send_notifications: true,
                              options: { authorization: token })
      rescue => error
        next if error.message == "duplicate"
        raise error
      end
    end
  end

  def no_location(attributes)
    attributes[:address].blank? ? true : false
  end
end
