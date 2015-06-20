ruby "1.9.3"

source 'http://rubygems.org'

gem "rake", "10.0.3"

gem "figaro"
gem "rails_config"

gem "rails", "= 3.2.18"
gem "aasm", "= 3.0.16"

#gem 'utf8-cleaner'
gem 'rack-robustness'

gem "authlogic", "= 3.3.0"
gem 'daemons', '~> 1.1.9'
gem "paperclip", "~> 3.0"
gem "mysql2"
gem "rubyzip", "~> 0.9.9"

gem "dotenv-rails", '~> 0.7.0'

gem "haml"

gem "rails-i18n", '~> 0.7.3'
gem 'jquery-rails', '~> 2.1'

gem 'dalli'

group :pdf do
  gem 'wkhtmltopdf-binary', :git=>"https://github.com/amekelburg/wkhtmltopdf-binary"
  gem 'wicked_pdf', '~> 0.9.6'
end

gem 'rest-client'
gem 'diffy'
gem 'asset_sync'

group :development, :test do
  gem "rspec-rails", "~> 2.10.1"
  #gem "rspec-spies",  "2.1.1"
  
  gem "rr", "= 0.10.11"
  
  gem "cucumber-rails", "1.1.0", :require=>false
  gem "webrat"
  gem "factory_girl_rails", :require=>false
  gem "database_cleaner"
  gem "shoulda"
  gem 'simplecov', :require => false
  
  gem "treetop", "= 1.4.10"
  # gem "selenium-client", "= 1.2.16"
  gem "capistrano", "= 2.15.5"
  gem "rvm-capistrano"
  
  # Pito:
  gem "hpricot", "0.8.6"
  gem "sqlite3"
  
  gem "assert_difference"
  
end

group :test do
  gem "capybara-webkit", "~> 0.7.1"
  
  gem "webmock"
end

group :assets do
  gem 'therubyracer'
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem "nokogiri", "= 1.5.9"
gem "mechanize", "= 2.7.1"
gem "newrelic_rpm", "= 3.6.0.83"
gem "airbrake"
gem "ledermann-rails-settings", :require => "rails-settings"

gem 'json'

gem "delayed_job_active_record", "~> 0.4.4"
