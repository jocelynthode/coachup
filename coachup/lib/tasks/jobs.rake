require 'dotenv/tasks' if Rails.env == 'development'

namespace :jobs do

  desc "Mail a reminder to courses participants before a training session"
  task :session_reminder => :environment do
    tomorrow = 1.day.from_now
    Course.where('ends_at > ?', 2.day.ago).each do |course|
      if course.retrieve_schedule.occurs_on? tomorrow then
        byebug
        course.subscriptions.each do |sub|
          CourseMailer.session_reminder(sub).deliver_now
        end
      end
    end
  end

  desc "Send test mail"
  task :sometest => :environment do
    c = Course.first
    CourseMailer.user_application(c, c.subscriptions.first.user).deliver_now
  end

end
