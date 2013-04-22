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
# General

Then /^I should see error messages$/ do
  page.should have_selector("span.error")
end

Then /^I should not see error messages$/ do
  page.should_not have_selector("span.error")
end

# Database

Given /^no partner exists with a login of "(.*)"$/ do |login|
  assert_nil Partner.find_by_login(login)
end

Given /^I registered with "(.*)\/(.*)"$/ do |login, password|
  partner = FactoryGirl.create :partner,
    :username              => login,
    :password              => password,
    :password_confirmation => password
end 

# Session

Then /^I should be logged in$/ do
  assert_not_nil PartnerSession.find #controller.send(:current_partner_session)
end

Then /^I should be logged out$/ do
  assert_nil PartnerSession.find #controller.send(:current_partner_session)
end

When /^session is cleared$/ do
  request.reset_session
  controller.instance_variable_set(:@current_partner, nil)
  controller.instance_variable_set(:@current_partner_session, nil)
end

Then /^I should be forbidden$/ do
  assert_response :forbidden
end

Given /^I am logged in as a valid partner$/ do
  partner = FactoryGirl.create(:partner)
  step %Q{I log in as "#{partner.username}/password"}
end

# Actions

When /^I log in as "(.*)\/(.*)"$/ do |login, password|
  step %{I go to the login page}
  step %{I fill in "Login" with "#{login}"}
  step %{I fill in "Password" with "#{password}"}
  step %{I press "Log in"}
end

# When /^I request password reset link to be sent to "(.*)"$/ do |login|
#   When %{I go to the password reset request page}
#   And %{I fill in "Email address" with "#{login}"}
#   And %{I press "Reset password"}
# end

When /^I update my password with "(.*)\/(.*)"$/ do |password, confirmation|
  step %{I fill in "Choose password" with "#{password}"}
  step %{I fill in "Confirm password" with "#{confirmation}"}
  step %{I press "Save this password"}
end

When /^I return next time$/ do
  When %{session is cleared}
  And %{I go to the homepage}
end
