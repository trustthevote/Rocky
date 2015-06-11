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
require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe StateOnlineRegistrationsController do
  before(:each) do
    Partner.any_instance.stub(:valid_api_key?).and_return(true)
  end
  
  describe "#show" do
    it "assigns the current registrant" do
      reg = FactoryGirl.create(:step_1_registrant)
      get :show, :registrant_id => reg.to_param
      assert assigns[:registrant]
    end
    it "sets the finish_with_state flag for the registrant to true" do
      reg = FactoryGirl.create(:step_1_registrant)
      GeoState.stub(:states_with_online_registration).and_return([reg.home_state_abbrev])
      reg.finish_with_state.should be_falsey
      get :show, :registrant_id => reg.to_param
      assigns[:registrant].finish_with_state.should be_truthy
    end
    it "assigns the iFrame url" do
      reg = FactoryGirl.create(:step_1_registrant, :home_zip_code=>"99400")
      get :show, :registrant_id => reg.to_param
      assert assigns[:online_registration_iframe_url]
    end
    it "renders the show template" do
      reg = FactoryGirl.create(:step_1_registrant)
      get :show, :registrant_id => reg.to_param
      assert_template "show"
    end
    
    it "renders a state template if it exists" do
      reg = FactoryGirl.create(:step_1_registrant, :home_state_id=>GeoState['CA'].id)
      File.stub(:exists?)
      RockyConf.ovr_states.CA.stub(:redirect_to_online_reg_url).and_return(false)
      File.stub(:exists?).with(File.join(Rails.root,"app/views/state_online_registrations/#{reg.home_state_abbrev.downcase}.html.erb")) { true }
      expect {
        get :show, :registrant_id => reg.to_param
      }.to raise_error(ActionView::MissingTemplate, /Missing template state_online_registrations\/#{reg.home_state_abbrev.downcase}/)
      
      #assert_template "#{reg.home_state_abbrev.downcase}"
      
    end
  end
end