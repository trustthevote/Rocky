namespace :covr do
  desc "Test all responses"
  task :test_expected_responses => :environment do
    require './lib/integrations/ca/covr/ca_covr_test'
    CaCovrTest.test_all!
  end
  
end
