ActionMailer::Base.smtp_settings = {
  :port =>           '587',
  :address =>        'smtp.mandrillapp.com',
  :user_name =>      CONFIG["mandrill_username"],
  :password =>       CONFIG["mandrill_api_key"],
  :domain =>         'touch-base.com',
  :authentication => :plain
}