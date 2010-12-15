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

describe Step5Controller do
  describe "#show" do
    it "should show the step 5 input form" do
      reg = Factory.create(:step_4_registrant)
      get :show, :registrant_id => reg.to_param
      assert assigns[:registrant].step_4?
      assert_template "show"
    end
  end

  describe "#update" do
    before(:each) do
      @registrant = Factory.create(:step_4_registrant)
      stub(@registrant).generate_pdf
      stub(Registrant).find_by_param.with(anything).returns(@registrant)
    end

    it "should update registrant and complete step 5" do
      put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_5_registrant)
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].complete?
      assert_redirected_to registrant_download_url(assigns[:registrant])
    end

    it "should reject invalid input and show form again" do
      put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_5_registrant, :attest_true => false)
      assert assigns[:registrant].step_5?
      assert assigns[:registrant].reload.step_4?
      assert_template "show"
    end

    describe "completing registration" do
      it "invokes wrap_up on registrant" do
        mock(@registrant).wrap_up
        put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_5_registrant)
      end

      it "can't submit updates twice" do
        assert_raises(ActiveRecord::RecordNotFound) do
          put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_5_registrant)
          put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_5_registrant)
        end
      end
    end
  end
end
