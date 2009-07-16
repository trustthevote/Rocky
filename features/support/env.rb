# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] ||= "cucumber"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'

# Comment out the next line if you don't want Cucumber Unicode support
require 'cucumber/formatter/unicode'

#Seed the DB
Fixtures.reset_cache  
fixtures_folder = File.join(RAILS_ROOT, 'test', 'fixtures')
fixtures = Dir[File.join(fixtures_folder, '*.{yml,csv}')].map {|f| File.basename(f, '.*') }
Fixtures.create_fixtures(fixtures_folder, fixtures)

# Comment out the next line if you want Rails' own error handling
# (e.g. rescue_action_in_public / rescue_responses / rescue_from)
Cucumber::Rails.bypass_rescue

require 'webrat'

Webrat.configure do |config|
  config.mode = :rails
end

require 'cucumber/rails/rspec'
require 'webrat/core/matchers'
require 'factory_girl'
Factory.find_definitions

