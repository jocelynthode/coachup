require 'dotenv/tasks' if Rails.env == 'development'

namespace :jobs do

  desc "Send test mail"
  task :sometest => :environment do
    c = Course.first
    m = CourseMailer.user_application(c, c.subscriptions.first.user)
    puts m
    m.deliver_now
  end

end
