require 'dotenv/tasks' if Rails.env == 'development'

namespace :jobs do

  desc "Send test mail"
  task :sometest => :environment do
    CourseMailer.user_application(nil, ENV['MAIL']).deliver_now
    puts 'mail sent'
  end
end
