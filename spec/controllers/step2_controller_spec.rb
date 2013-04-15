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

describe Step2Controller do
  describe "#show" do
    it "should show the step 2 input form" do
      reg = FactoryGirl.create(:step_1_registrant)
      get :show, :registrant_id => reg.to_param
      assert_template "show"
    end
    it "sets up tooltip and party variables" do
      reg = FactoryGirl.create(:step_1_registrant)
      stub(reg).state_parties { true } 
      stub(reg).race_tooltip { true } 
      stub(reg).party_tooltip { true } 
      stub(Registrant).find_by_param! { reg }
      get :show, :registrant_id => reg.to_param
      assert assigns[:state_parties]
      assert assigns[:race_tooltip]
      assert assigns[:party_tooltip]
    end
  end

  describe "#update" do
    before(:each) do
      @registrant = FactoryGirl.create(:step_1_registrant)
    end

    it "should update registrant and complete step 2" do
      put :update, :registrant_id => @registrant.to_param, :registrant => FactoryGirl.attributes_for(:step_2_registrant)
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].step_2?
      assert_redirected_to registrant_step_3_url(assigns[:registrant])
    end

    it "should reject invalid input and show form again" do
      put :update, :registrant_id => @registrant.to_param, :registrant => FactoryGirl.attributes_for(:step_2_registrant, :first_name => nil)
      assert assigns[:registrant].step_2?
      assert assigns[:registrant].reload.step_1?
      assert_template "show"
    end

    it "should notice disabled javascript and override has_mailing_address" do
      put :update, :registrant_id => @registrant.to_param,
                   :registrant => FactoryGirl.attributes_for(:step_2_registrant, :mailing_address => "submitted", :has_mailing_address => "0"),
                   :javascript_disabled => "1"
      assert assigns[:registrant].invalid?
      assert_template "show"
    end

    it "should respect when has_mailing_address is checked and javascript disabled" do
      put :update, :registrant_id => @registrant.to_param,
                   :registrant => FactoryGirl.attributes_for(:step_2_registrant, :mailing_address => "", :has_mailing_address => "1"),
                   :javascript_disabled => "1"
      assert assigns[:registrant].invalid?
      assert_template "show"
    end
    
    it "should show the state-specific system when registrant_state_online_registration button is pressed" do
      put :update, :registrant_id => @registrant.to_param, 
                   :registrant => FactoryGirl.attributes_for(:step_2_registrant, :has_state_license=>true),
                   :registrant_state_online_registration => ""
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].step_2?
      assert assigns[:registrant].using_state_online_registration?
      assert_redirected_to registrant_state_online_registration_url(assigns[:registrant])
    end
    
    it "should go to the confirmation page if using a short_form" do
      stub(@registrant).use_short_form? { true }      
      stub(Registrant).find_by_param! { @registrant }
      put :update, :registrant_id => @registrant.to_param, :registrant => FactoryGirl.attributes_for(:maximal_registrant)
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].complete?
      assert_redirected_to registrant_download_url(assigns[:registrant])
    end
    
  end
end
