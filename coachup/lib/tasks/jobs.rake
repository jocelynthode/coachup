require 'dotenv/tasks' if Rails.env == 'development'

namespace :jobs do

  desc "Add CyberCoach entries for training sessions that happened yesterday"
  task :training_entries => :environment do
    yesterday = 1.day.ago
    Course.where('ends_at > ?', yesterday - 1.day).each do |course|
      schedule = course.retrieve_schedule
      next if not schedule.occurs_on? yesterday

      entrydate = schedule.next_occurrence yesterday
      entry = {
        entrydate: entrydate,
        comment: course.title,
        entrylocation: course.location.address,
        entryduration: course.duration.seconds_since_midnight.to_int,
        publicvisible: '2'
      }
      entryroot = 'entry' + course.sport.downcase
      payload_xml = entry.to_xml(root: entryroot, skip_instruct: true)
      course.subscriptions.each do |sub|
        url = "users/#{sub.user.username}/#{course.sport}"
        response = rest_request(:post, url,
                                payload: payload_xml,
                                user: sub.user.username,
                                password: sub.user.password,
                                headers: {content_type: :xml})
        if bad_request?(response)
          puts "Error while adding entry on CyberCoach: #{response}"
        end
      end
    end
  end

  desc "Mail a reminder to courses participants before a training session"
  task :session_reminder => :environment do
    tomorrow = 1.day.from_now
    Course.where('ends_at > ?', 2.day.ago).each do |course|
      if course.retrieve_schedule.occurs_on? tomorrow then
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

  private
    def rest_request(method, url, **args)
      begin
        url = 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/' + url
        args[:headers] ||= {}
        args[:headers].merge!({accept: 'json'})
        response = RestClient::Request.execute(method: method, url: url, **args)
        JSON.parse(response, symbolize_names: true)
      rescue RestClient::Exception => exception
        exception
      end
    end

    def bad_request?(response)
      if response.is_a?(RestClient::Exception)
        true
      else
        false
      end
    end
end
