# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'simplecov'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
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
  
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.fixture_path =  "#{::Rails.root}/db/fixtures"
  config.use_transactional_fixtures = true
  #config.use_instantiated_fixtures  = false
  
  config.global_fixtures = :all
  

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
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
