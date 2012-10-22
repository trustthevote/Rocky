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



Given /^that partner's css file exists$/ do
  stub(File).exists?.returns(true)
end

Given /^that partner's css file does not exist$/ do
  stub(File).exists?.returns(false)
end



Then /^I should see a link to the standard CSS$/ do
  response.body.should include("link href=\"/stylesheets/application.css")
  response.body.should include("link href=\"/stylesheets/registration.css")
end


Then /^I should see a link to that partner's CSS$/ do
  response.body.should include("link href=\"/partners/#{@partner.id}/application.css")
  response.body.should include("link href=\"/partners/#{@partner.id}/registration.css")
end
