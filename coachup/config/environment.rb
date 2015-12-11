# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Mail configuration
ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SMTP_USERNAME'],
    :password       => ENV['SMTP_PASSWORD'],
    :domain         => 'coachup.heroku.com',
    :enable_starttls_auto => true
}
