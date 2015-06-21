# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
require 'rails_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/active_model/mocks'
#require 'rspec/collection_matchers'
# Add additional requires below this line. Rails is not loaded until this point!



require 'csv'

require 'paperclip/matchers'

require 'authlogic/test_case'

require 'factory_girl_rails'

require 'webmock'
require 'webmock/rspec'

WebMock.allow_net_connect!


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}




# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include AssertDifference
  config.include Paperclip::Shoulda::Matchers
  config.include Authlogic::TestCase
  
  config.include Capybara::RSpecMatchers, :type => :view
  config.include Capybara::RSpecMatchers, :type => :helper
  
  config.include Rails.application.routes.url_helpers, :type=>:helper
  
  config.include Capybara::RSpecMatchers, :type => :mailer
  config.include Capybara::RSpecMatchers, :type => :controller
  config.include Capybara::DSL, :type => :controller
  config.include Capybara::DSL, :type => :request
  
  
  config.include SpecHelperMethods
  config.include ApiHelperMethods
  
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path =  "#{::Rails.root}/db/fixtures"
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  
  config.global_fixtures = :all

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  
  config.infer_base_class_for_anonymous_controllers = true

  config.infer_spec_type_from_file_location!

  
  config.before(:each) do
    stub_request(:any, %r{http://example-api\.com/api/v3/partners/\d+\.json}).to_return do |req|
      req.uri.to_s =~ /(\d+)\.json(\?.+)?$/
      id = $1
      {:body=>{:partner => V3::PartnerService.find({:partner_id=>id, :partner_api_key=>'abc123'}) }.to_json}
    end
    stub_request(:any, %r{http://example-api\.com/api/v3/registrations.json}).to_return do |req|
      {:body=>{:pdfurl=>"http://example-api/pdfurl.pdf", :uid=>"uid"}.to_json}
    end
    
    stub_request(:any, %r{http://example-api\.com/api/v3/registrations/bulk.json}).to_return do |req|
      json = JSON.parse(req.body).deep_symbolize_keys
      r = {:body=>{
        :registrants_added=>V3::RegistrationService.bulk_create(json[:registrants], json[:partner_id], json[:partner_API_key])
      }.to_json}
      r
    end
    
  end
  
  
end
