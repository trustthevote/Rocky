#***** BEGIN LICENSE BLOCK *****
#
#Version: RTV Public License 1.0
#
#The contents of this file are subject to the RTV Public License Version 1.0 (the
#"License"); you may not use this file except in compliance with the License. You
#may obtain a copy of the License at: http://www.osdv.org/license12b/
#
#Software distributed under the License is distributed on an "AS IS" basis,
#WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
#specific language governing rights and limitations under the License.
#
#The Original Code is the Online Voter Registration Assistant and Partner Portal.
#
#The Initial Developer of the Original Code is Rock The Vote. Portions created by
#RockTheVote are Copyright (C) RockTheVote. All Rights Reserved. The Original
#Code contains portions Copyright [2008] Open Source Digital Voting Foundation,
#and such portions are licensed to you under this license by Rock the Vote under
#permission of Open Source Digital Voting Foundation.  All Rights Reserved.
#
#Contributor(s): Open Source Digital Voting Foundation, RockTheVote,
#                Pivotal Labs, Oregon State University Open Source Lab.
#
#***** END LICENSE BLOCK *****
Given /^I have completed step (\d+)$/ do |step_num|
  @registrant = Factory.create("step_#{step_num}_registrant")
end

Given /^I have completed step (\d+) from that partner$/ do |step_num|
  @registrant = Factory.create("step_#{step_num}_registrant")
  @registrant.partner = Partner.last
  @registrant.save!
end

Given /^I have completed step (\d+) as a resident of "([^\"]*)" state$/ do |step_num,state_name|
  state = GeoState.find_by_name(state_name)
  zip_prefix = GeoState.zip3map.index(state.abbreviation)
  @registrant = Factory.create("step_#{step_num}_registrant", :home_zip_code=>zip_prefix+'01')
end

Given /^I have been to the state online registration page$/ do
  Given 'I have completed step 4 as a resident of "Washington" state'
  @registrant.update_attributes!(:finish_with_state=>true)
end


Given /^I have completed step (\d+) as a resident of "([^\"]*)" state from that partner$/ do |step_num,state_name|
  geo_state = GeoState.find_by_name(state_name)
  zip = GeoState.zip5map.invert[geo_state.abbreviation] || GeoState.zip3map.invert[geo_state.abbreviation]
  @registrant = Factory.create("step_#{step_num}_registrant", :home_zip_code=>zip+'00')
  @registrant.partner = Partner.last
  @registrant.save!
end

Given /^I have completed step (\d+) as a resident of "([^\"]*)" state without javascript$/ do |step_num,state_name|
  geo_state = GeoState.find_by_name(state_name)
  zip = GeoState.zip5map.invert[geo_state.abbreviation] || GeoState.zip3map.invert[geo_state.abbreviation]
  @registrant = Factory.create("step_#{step_num}_registrant", :home_zip_code=>zip+'00')
  @registrant.partner = Partner.last
  @registrant.javascript_disabled = true
  @registrant.save!
end


When /^my session expires$/ do
  @registrant.reload
  Registrant.record_timestamps = false
  @registrant.update_attributes!(:updated_at=>(2*Registrant::STALE_TIMEOUT).seconds.ago)
  Registrant.record_timestamps = true
end


When /^the timeout_stale_registrations task has run$/ do
  Registrant.abandon_stale_records
end

Then /^I should be sent a thank\-you email$/ do
  email = ActionMailer::Base.deliveries.last
  email.to.should include(@registrant.email_address)
  email.subject.should == "Thank You TBD"
end

Then /^I should not be sent a thank\-you email$/ do
  ActionMailer::Base.deliveries.count.should == 0
end


Then /^my status should be "([^\"]*)"$/ do |status|
  @registrant.reload
  @registrant.status.should == status
end

Then /^my status should not be "([^\"]*)"$/ do |status|
  @registrant.reload
  @registrant.status.should_not == status
end


When /^I am (\d+) years old$/ do |age|
  fill_in("registrant_date_of_birth", :with => age.to_i.years.ago.to_date.strftime("%m/%d/%Y"))
end

Given /^I have not set a locale$/ do
  I18n.locale = nil
end

Given /^my locale is "([^\"]*)"$/ do |arg1|
  I18n.locale = "es"
  @registrant.locale = "es"
  @registrant.save!
end


Given /^I am a first time registrant$/ do
  @registrant.first_registration = true
  @registrant.save
end

Given /^my phone number is not blank$/ do
  @registrant.phone = "415-555-1234"
  @registrant.phone_type = "Mobile"
  @registrant.save
end

Given /^I have not downloaded the PDF before$/ do
  `rm -f #{@registrant.pdf_file_path}`
end

Given /there is localized state data/ do
  @registrant.home_state.localizations << StateLocalization.new(:locale => 'en', :id_number_tooltip => 'local tooltip')
end

Then /^I should see a new download$/ do
  assert File.exists?(@registrant.pdf_file_path)
end

Then /^I should see my email$/ do
  Then %Q{the "Email" field should contain "#{@registrant.email_address}"}
end

Then /^I should see my date of birth$/ do
  Then %Q{the "Date of Birth" field should contain "#{@registrant.date_of_birth.year}"}
end

Then /^I should see "([^\"]*)" in select box "([^\"]*)"$/ do |select_value, select_box|
  assert_equal select_value, current_dom.css("##{select_box} option[selected]").text
end


Then /^I should be signed up for "([^\"]*)"$/ do |flag|
  @registrant.reload
  @registrant.send(flag).should be_true
end

Then /^I should not be signed up for "([^\"]*)"$/ do |flag|
  @registrant.reload
  @registrant.send(flag).should be_false
end

Then /^I should be recorded as having selected to finish with the state$/ do
  @registrant.reload
  @registrant.finish_with_state.should be_true
end

Then /^I should not be recorded as having selected to finish with the state$/ do
  @registrant.reload
  @registrant.finish_with_state.should be_false
end



When /^I enter valid data for step 1$/ do
  When %Q{I fill in "email address" with "john.public@example.com"}
  And %Q{I fill in "zip code" with "94113"}
  And %Q{I am 20 years old}
  And %Q{I check "I am a U.S. citizen"}
end

When /^I live in (.*)$/ do |state_name|
  state = GeoState.find_by_name(state_name)
  zip_prefix = GeoState.zip3map.index(state.abbreviation)
  When %Q{I fill in "zip code" with "#{zip_prefix}01"}
end


Then /^I should see an iFrame for the Washington State online system$/ do
  @registrant = Registrant.last #need to reload @registrant because data has been submitted
  fn = CGI.escape @registrant.first_name.to_s
  ln = CGI.escape @registrant.last_name.to_s
  dob= CGI.escape @registrant.form_date_of_birth.to_s.gsub('-','/')
  lang = @registrant.locale.to_s
  state_url="https://weiapplets.sos.wa.gov/myvote/myvote?language=#{lang}&Org=RocktheVote&firstname=#{fn}&lastName=#{ln}&DOB=#{dob}"
  response.body.should have_xpath("//iframe[@src='#{state_url}']")
end


Then /^I should see an iFrame for the Arizona State online system$/ do
  state_url = "https://servicearizona.com/webapp/evoter/selectLanguage"
  response.body.should have_xpath("//iframe[@src='#{state_url}']")  
end

Then /^I should see an iFrame for the California State online system$/ do
  state_url = "https://www.sos.ca.gov/elections/register-to-vote/"
  response.body.should have_xpath("//iframe[@src='#{state_url}']")  
end
Then /^I should see an iFrame for the Colorado State online system$/ do
  state_url = "https://www.sos.state.co.us/Voter/secuVerifyExist.do"
  response.body.should have_xpath("//iframe[@src='#{state_url}']")  
end


Then /^my value for "([^\"]*)" should be "([^\"]*)"$/ do |method, value|
  @registrant = Registrant.last
  @registrant.send(method).to_s.should == value.to_s
end

When /^the partner changes "([^\"]*)" to "([^\"]*)"$/ do |method, value|
  @partner ||= Partner.last
  @partner.reload
  @partner.send("#{method}=", value)
  @partner.save!
end


After('@cleanup_pdf') do
  `rm #{@registrant.pdf_file_path}`
end
