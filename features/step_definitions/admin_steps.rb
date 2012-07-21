When /^I upload the "([^\"]*)" zip file$/ do |file_name|
  attach_file(:partner_zip_zip_file, File.join(RAILS_ROOT, 'spec', 'fixtures', 'files', file_name))
end

Then /^I should see that partner's api key$/ do
  @partner ||= Partner.last
  @partner.api_key.should_not be_blank
  response.should contain(@partner.api_key)
end


Given /^that partner's api key is "([^\"]*)"$/ do |key|
  @partner ||= Partner.last
  @partner.update_attributes!(:api_key=>key)
end


Then /^that partner's api key should not be "([^\"]*)"$/ do |old_key|
  @partner ||= Partner.last
  @partner.reload
  @partner.api_key.should_not == old_key
end
