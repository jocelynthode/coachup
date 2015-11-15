Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT'], ENV['GOOGLE_SECRET'], {
    :scope => 'email,calendar'
  }
end
