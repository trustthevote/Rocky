# encoding: utf-8

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

Before do
  MobileConfig.stub(:is_mobile_request?) {false}
  Integrations::Soap.stub(:make_request) do
    File.new(Rails.root.join("spec/fixtures/files/covr/max_registrant_response.xml")).read
  end
end

# Given /^I am using a mobile browser$/ do
#   MobileConfig.stub(:is_mobile_request?) { true }
#   puts MobileConfig.redirect_url
# end


Given /^I have completed step (\d+)$/ do |step_num|
  @registrant = FactoryGirl.create("step_#{step_num}_registrant")
  switch_partner_to_remote(@registrant)
end

Given(/^my zip code is "(.*?)"$/) do |zip|
  @registrant.update_attributes(:home_zip_code=>zip)
end

Given /^I have completed step (\d+) for a short form$/ do |step_num|
  @registrant = FactoryGirl.create("step_#{step_num}_registrant", :short_form=>true)
  switch_partner_to_remote(@registrant)
  
end

Given /^I have completed step (\d+) for a short form as a resident of "([^\"]*)"$/ do |step_num, state_name|
  state = GeoState.find_by_name(state_name)
  zip_prefix = GeoState.zip3map.key(state.abbreviation)
  @registrant = FactoryGirl.create("step_#{step_num}_registrant", :home_zip_code=>zip_prefix+'01', :short_form=>true)
  switch_partner_to_remote(@registrant)
  
end

Given /^I have completed step (\d+) from that partner$/ do |step_num|
  @registrant = FactoryGirl.create("step_#{step_num}_registrant")
  @registrant.partner = Partner.last
  switch_partner_to_remote(@registrant)
  
  @registrant.save!
end

Given /^I have completed step (\d+) as a resident of "([^\"]*)" state$/ do |step_num,state_name|
  state = GeoState.find_by_name(state_name)
  zip_prefix = GeoState.zip3map.key(state.abbreviation)
  @registrant = FactoryGirl.create("step_#{step_num}_registrant", :home_zip_code=>zip_prefix+'01')
  switch_partner_to_remote(@registrant)
  
end

Given /^I have completed step (\d+) from that partner as a resident of "([^\"]*)" state$/ do |step_num,state_name|
  state = GeoState.find_by_name(state_name)
  zip_prefix = GeoState.zip3map.key(state.abbreviation)
  @registrant = FactoryGirl.create("step_#{step_num}_registrant", :home_zip_code=>zip_prefix+'01')
  @registrant.partner = Partner.last
  switch_partner_to_remote(@registrant)
  
  @registrant.save!
end


Given(/^I have completed step (\d+) without an email address$/) do |step_num|
  @registrant = FactoryGirl.create("step_#{step_num}_registrant", :collect_email_address=>'no', :email_address=>nil)
  switch_partner_to_remote(@registrant)
  
end

Given(/^I have completed step (\d+) as a resident of "(.*?)" state without an email address$/) do |step_num,state_name|
  state = GeoState.find_by_name(state_name)
  zip_prefix = GeoState.zip3map.key(state.abbreviation)
  @registrant = FactoryGirl.create("step_#{step_num}_registrant", :home_zip_code=>zip_prefix+'01', :collect_email_address=>'no', :email_address=>nil)  
  switch_partner_to_remote(@registrant)
  
end



Given(/^there is a stylesheet for Spanish$/) do
  File.stub(:exists?)
  File.stub(:exists?).with(Translation.css_path('es')).and_return(true)
end

Then(/^the Spanish style sheet should be included$/) do
  page.should have_xpath("//link[@href='/assets/locales/es.css']")
end

Given(/^there is not a stylesheet for Spanish$/) do
  File.stub(:exists?)
  File.stub(:exists?).with(Translation.css_path('es')).and_return(false)
end

Then(/^the Spanish style sheet should not be included$/) do
  page.should_not have_xpath("//link[@href='/assets/locales/es.css']")
end



Given /^I have been to the state online registration page$/ do
  step 'I have completed step 4 as a resident of "Washington" state'
  @registrant.update_attributes!(:finish_with_state=>true)
end


Given /^I have completed step (\d+) as a resident of "([^\"]*)" state from that partner$/ do |step_num,state_name|
  geo_state = GeoState.find_by_name(state_name)
  zip = GeoState.zip5map.invert[geo_state.abbreviation] || GeoState.zip3map.invert[geo_state.abbreviation]
  @registrant = FactoryGirl.create("step_#{step_num}_registrant", :home_zip_code=>zip+'00')
  @registrant.partner = Partner.last
  switch_partner_to_remote(@registrant)
  
  @registrant.save!
end

Given /^I have completed step (\d+) as a resident of "([^\"]*)" state without javascript$/ do |step_num,state_name|
  geo_state = GeoState.find_by_name(state_name)
  zip = GeoState.zip5map.invert[geo_state.abbreviation] || GeoState.zip3map.invert[geo_state.abbreviation]
  @registrant = FactoryGirl.create("step_#{step_num}_registrant", :home_zip_code=>zip+'00')
  @registrant.partner = Partner.last
  switch_partner_to_remote(@registrant)
  
  @registrant.javascript_disabled = true
  @registrant.save!
end


When /^my session expires$/ do
  @registrant.reload
  Registrant.record_timestamps = false
  @registrant.update_attributes!(:updated_at=>(2*Registrant.stale_timeout).seconds.ago)
  Registrant.record_timestamps = true
end


When /^the timeout_stale_registrations task has run$/ do
  Registrant.abandon_stale_records
end


When(/^the process_ui_records task has run$/) do
  Registrant.process_ui_records
end

# Then /^I should be redirected to the mobile url with partner="([^\"]*)"$/ do |partner|
#   response.should redirect_to(MobileConfig.redirect_url(:partner=>partner,:locale=>'en'))
# end
# 
# Then /^I should be redirected to the mobile url with partner="([^\"]*)", source="([^\"]*)" and tracking="([^\"]*)"$/ do |partner,source,tracking|
#   response.should redirect_to(MobileConfig.redirect_url(:partner=>partner,:locale=>'en', :source=>source, :tracking=>tracking))
# end

Then(/^my confirmation email should include "(.*?)"$/) do |text|
  email = ActionMailer::Base.deliveries.last
  email.body.should include(text)
end

Then /^I should be sent a thank\-you email$/ do
  email = ActionMailer::Base.deliveries.last
  email.to.should include(@registrant.email_address)
  email.subject.should == "Thank you for using the online voter registration tool"
end

Given(/^that partner has a custom thank\-you external email$/) do
  @partner ||= Partner.last
  EmailTemplate.set(@partner, "thank_you_external.en", "Custom partner for <%= @registrant_home_state_name %>, <%= @registrant_home_state_abbrev %>")
end

Then /^I should be sent a thank\-you email from that partner$/ do
  @partner ||= Partner.last
  registrant = Registrant.last
  email = ActionMailer::Base.deliveries.last
  email.to.should include(@registrant.email_address)
  email.from.should include(@partner.from_email)
  email.subject.should == "Thank you for using the online voter registration tool"
  email.body.should == "Custom partner for #{registrant.home_state_name}, #{registrant.home_state_abbrev}"
end

Then /^I should be sent a thank\-you email from RTV$/ do
  email = ActionMailer::Base.deliveries.last
  email.to.should include(@registrant.email_address)
  email.from.should include(RockyConf.from_address)
  email.subject.should == "Thank you for using the online voter registration tool"
end

Then /^I should be sent a thank\-you email in spanish$/ do
  email = ActionMailer::Base.deliveries.last
  email.to.should include(@registrant.email_address)
  email.subject.should == "Gracias por usar el instrumento de registración de votantes en línea"
end

Then /^I should be sent a thank\-you email in korean$/ do
  email = ActionMailer::Base.deliveries.last
  email.to.should include(@registrant.email_address)
  email.subject.should == "온라인 유권자 등록을 이용해 주셔서 감사합니다"
end

Then /^I should not be sent a thank\-you email$/ do
  ActionMailer::Base.deliveries.count.should == 0
end


Then /^my status should be "([^\"]*)"$/ do |status|
  Registrant.last.status.should == status
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

Given /^my locale is "([^\"]*)"$/ do |locale|
  I18n.locale = locale
  @registrant.locale = locale
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

Given(/^I have a state license$/) do
  @registrant.has_state_license = true
  @registrant.save
end

Given(/^the PDF is not ready$/) do
  Registrant.any_instance.stub(:remote_pdf_ready?).and_return(false)
  Registrant.any_instance.stub(:remote_uid).and_return("auid")
end

Given /there is localized state data/ do
  @registrant.home_state.localizations << StateLocalization.new(:locale => 'en', :id_number_tooltip => 'local tooltip')
end

Then /^I should see a new download$/ do
  assert File.exists?(Registrant.last.pdf_file_path)
end

Then /^I should see my email$/ do
  step %Q{the "Email" field should contain "#{@registrant.email_address}"}
end

Then /^I should see my date of birth$/ do
  step %Q{the "Date of Birth" field should contain "#{@registrant.date_of_birth.year}"}
end

Then /^I should see "([^\"]*)" in select box "([^\"]*)"$/ do |select_value, select_box|
  assert_equal select_value, page.all("##{select_box} option[selected]").first.text
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
  step %Q{I fill in "Email Address" with "john.public@example.com"}
  step %Q{I fill in "ZIP Code" with "94113"}
  step %Q{I am 20 years old}
  step %Q{I check "I am a U.S. citizen"}
end

When /^I live in (.*)$/ do |state_name|
  state = GeoState.find_by_name(state_name)
  zip_prefix = GeoState.zip3map.key(state.abbreviation)
  step %Q{I fill in "ZIP Code" with "#{zip_prefix}01"}
end


Then /^I should see an iFrame for the Washington State online system$/ do
  @registrant = Registrant.last #need to reload @registrant because data has been submitted
  fn = CGI.escape @registrant.first_name.to_s
  ln = CGI.escape @registrant.last_name.to_s
  dob= CGI.escape @registrant.form_date_of_birth.to_s.gsub('-','/')
  lang = @registrant.locale.to_s
  state_url="https://weiapplets.sos.wa.gov/myvote/myvote?language=#{lang}&Org=RocktheVote&firstname=#{fn}&lastname=#{ln}&DOB=#{dob}"
  page.should have_xpath("//iframe[@src='#{state_url}']")
end


Then /^I should see an iFrame for the Arizona State online system$/ do
  state_url = "https://servicearizona.com/webapp/evoter/selectLanguage"
  page.should have_xpath("//iframe[@src='#{state_url}']")  
end

Then /^I should see an iFrame for the California State online system$/ do
  state_url = "https://rtv.sos.ca.gov/elections/register-to-vote"
end

Then /^I should see a link to the CA online registration system$/ do
  state_url = "http://www.registertovote.ca.gov/"
  page.should have_xpath("//a[@href='#{state_url}']")  
end


Then /^I should see an iFrame for the Colorado State online system$/ do
  state_url = "https://www.sos.state.co.us/Voter/secuVerifyExist.do"
  page.should have_xpath("//iframe[@src='#{state_url}']")  
end

Then /^I should see an iFrame for the Nevada State online system$/ do
  @registrant = Registrant.last #need to reload @registrant because data has been submitted
  fn = CGI.escape @registrant.first_name.to_s
  mn = CGI.escape @registrant.middle_name.to_s
  ln = CGI.escape @registrant.last_name.to_s
  sf = CGI.escape @registrant.name_suffix.to_s
  zip = CGI.escape @registrant.home_zip_code.to_s
  lang = @registrant.locale.to_s
  
  state_url="https://nvsos.gov/sosvoterservices/Registration/step1.aspx?source=rtv&utm_source=rtv&utm_medium=rtv&utm_campaign=rtv&fn=#{fn}&mn=#{mn}&ln=#{ln}&lang=#{lang}&zip=#{zip}&sf=#{sf}"
  page.should have_xpath("//iframe[@src='#{state_url}']")
  
end

Then /^I should see "([^\"]*)" unless the state is "([^\"]*)"$/ do |content, abbr|
  if @registrant.home_state_abbrev.downcase != abbr.downcase
    page.should have_content(content)
  end
end


Then /^I should see the text "([^\"]*)" unless the state is "([^\"]*)"$/ do |content, abbr|
  if @registrant.home_state_abbrev.downcase != abbr.downcase
    page.should have_content(content)
  end
end


Then /^when the state is "([^\"]*)" the text should include "([^\"]*)"$/ do |abbr, content|
  if @registrant.home_state_abbrev.downcase == abbr.downcase
    page.should have_content(content)
  end
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

Given(/^COVR UI debugging is true$/) do
  RockyConf.ovr_states.CA.api_settings.debug_in_ui = true
end
Given(/^COVR UI debugging is false$/) do
  RockyConf.ovr_states.CA.api_settings.debug_in_ui = false
end

Given(/^the setting for allowing ask\-for\-volunteer is true$/) do
  RockyConf.sponsor.allow_ask_for_volunteers = true
end
Given(/^the setting for allowing ask\-for\-volunteer is false$/) do
  RockyConf.sponsor.allow_ask_for_volunteers = false
end

Given(/^COVR responses return failures$/) do
  Integrations::Soap.stub(:make_request) do
    File.new(Rails.root.join("spec/fixtures/files/covr/max_registrant_response_fail.xml")).read
  end
end

Given(/^COVR responses return successes$/) do
  Integrations::Soap.stub(:make_request) do
    File.new(Rails.root.join("spec/fixtures/files/covr/max_registrant_response.xml")).read
  end
end

Then(/^I should be redirected to the CA url for that registrant$/) do
  raise "'#{current_url}'".to_s
end

Then(/^I should see the return XML from the API request$/) do
  page.should have_content "s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope"
  page.should have_content "<Success>true</Success>"
end

When(/^I'm testing$/) do
  raise 'a'
end



After('@cleanup_pdf') do
  `rm #{@registrant.pdf_file_path}`
end
