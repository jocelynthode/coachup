require 'dotenv/tasks' if Rails.env == 'development'

namespace :jobs do

  desc "Mail a reminder to courses participants before a training session"
  task :session_reminder => :environment do
    tomorrow = 1.day.from_now
    Course.where('ends_at > ?', 2.day.ago).each do |course|
      if course.retrieve_schedule.occurs_on? tomorrow then
        course.subscriptions.each do |sub|
          m = CourseMailer.session_reminder(sub)
          puts m
          m.deliver_now
        end
      end
    end
  end

  desc "Send test mail"
  task :sometest => :environment do
    c = Course.first
    m = CourseMailer.user_application(c, c.subscriptions.first.user)
    puts m
    m.deliver_now
  end

end
