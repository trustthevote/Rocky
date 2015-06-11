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

describe Step3Controller do
  before(:each) do
    Partner.any_instance.stub(:valid_api_key?).and_return(true)
  end
  
  describe "#show" do
    it "should show the step 3 input form" do
      reg = FactoryGirl.create(:step_2_registrant)
      get :show, :registrant_id => reg.to_param
      assert assigns[:registrant].step_2?
      assert_template "show"
    end
    it "sets up tooltip, party and question variables" do
      reg = FactoryGirl.create(:step_2_registrant)
      reg.stub(:state_parties) { true } 
      reg.stub(:race_tooltip) { true } 
      reg.stub(:party_tooltip) { true } 
      Registrant.stub(:find_by_param!) { reg }
      get :show, :registrant_id => reg.to_param
      assert assigns[:state_parties]
      assert assigns[:race_tooltip]
      assert assigns[:party_tooltip]
      assert_not_nil assigns[:question_1]
      assert_not_nil assigns[:question_2]
      
    end
  end

  describe "#update" do
    before(:each) do
      @registrant = FactoryGirl.create(:step_2_registrant)
    end

    it "should update registrant and complete step 3" do
      put :update, :registrant_id => @registrant.to_param, :registrant => FactoryGirl.attributes_for(:step_3_registrant).reject {|k,v| k == :status }
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].step_3?
      assert_redirected_to registrant_step_4_url(assigns[:registrant])
    end

    it "should reject invalid input and show form again" do
      put :update, :registrant_id => @registrant.to_param, :registrant => FactoryGirl.attributes_for(:step_3_registrant, :state_id_number => nil).reject {|k,v| k == :status }
      assert assigns[:registrant].step_3?
      assert assigns[:registrant].reload.step_2?
      assert_template "show"
    end
    
    
  end
  


  
end
