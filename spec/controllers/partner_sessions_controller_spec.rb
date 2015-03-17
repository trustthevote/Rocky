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
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PartnerSessionsController do
  
  it "renders the page when partner portal not disabled" do
    @old_setting = RockyConf.disable_partner_portal
    RockyConf.disable_partner_portal = false
    
    get :new
    assert_response :success
    
    RockyConf.disable_partner_portal = @old_setting
  end
  
  it "redirects to home page when partner portal disabled" do
    @old_setting = RockyConf.disable_partner_portal
    RockyConf.disable_partner_portal = true
    
    get :new
    response.should redirect_to("/")
    
    RockyConf.disable_partner_portal = @old_setting
  end
  
end
