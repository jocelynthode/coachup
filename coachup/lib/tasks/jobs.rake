require 'dotenv/tasks' if Rails.env == 'development'

namespace :jobs do
  desc "Add CyberCoach entries for training sessions that happened yesterday"
  task :training_entries => :environment do
    yesterday = 1.day.ago
    Course.where('ends_at > ?', yesterday - 1.day).each do |course|
      schedule = course.retrieve_schedule
      next unless schedule.occurs_on?(yesterday)

      entrydate = schedule.next_occurrence(yesterday)
      entry = {
        entrydate: entrydate,
        comment: course.title,
        entrylocation: course.location.address,
        entryduration: course.duration.seconds_since_midnight.to_int,
        publicvisible: 2
      }
      course.subscriptions.each do |sub|
        coach_sub = CoachClient::UserSubscription.new(coach_client,
                                                      sub.user.username,
                                                      course.sport)
        coach_sub.user.password = sub.user.password
        coach_entry = CoachClient::Entry.new(coach_client, coach_sub, entry)
        begin
          coach_entry.create
        rescue CoachClient::Exception
          puts "Error while adding entry on CyberCoach"
        end
      end
    end
  end

  desc "Mail a reminder to courses participants before a training session"
  task :session_reminder => :environment do
    tomorrow = 1.day.from_now
    Course.where('ends_at > ?', 2.day.ago).each do |course|
      next unless course.retrieve_schedule.occurs_on?(tomorrow)
      course.subscriptions.each do |sub|
        CourseMailer.session_reminder(sub).deliver_now
      end
    end
  end

  desc "Send test mail"
  task :sometest => :environment do
    c = Course.first
    CourseMailer.user_application(c, c.subscriptions.first.user).deliver_now
  end

  private

  def coach_client
    CoachClient::Client.new('http://diufvm31.unifr.ch:8090',
                            '/CyberCoachServer/resources/')
  end
end
