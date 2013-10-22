ActionMailer::Base.delivery_method = Rails.env.production? ? :sendmail : :test
ActionMailer::Base.default_url_options[:host] = "waterflowseast.com"
