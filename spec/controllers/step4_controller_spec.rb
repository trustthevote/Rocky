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

describe Step4Controller do
  describe "#show" do
    it "should show the step 4 input form" do
      reg = Factory.create(:step_3_registrant)
      get :show, :registrant_id => reg.to_param
      assert assigns[:registrant].step_3?
      assert_not_nil assigns[:question_1]
      assert_not_nil assigns[:question_2]
      assert_template "show"
    end

    it "gets the questions for the current locale" do
      reg = Factory.create(:step_3_registrant)
      reg.partner.survey_question_1_en = "In English?"
      reg.partner.survey_question_1_es = "En Español?"
      reg.partner.save
      get :show, :registrant_id => reg.to_param
      assert_equal "In English?", assigns[:question_1]
      reg.locale = "es"
      reg.save(false)
      get :show, :registrant_id => reg.to_param
      assert_equal "En Español?", assigns[:question_1]
    end

    describe "when partner wants volunteers" do
      integrate_views
      it "should show volunteer checkbox" do
        partner = Factory.create(:partner, :ask_for_volunteers => true)

        reg = Factory.create(:step_3_registrant, :partner_id => partner.to_param)
        get :show, :registrant_id => reg.to_param

        assert_select "#registrant_volunteer"
      end
    end

    describe "when partner does not want volunteers" do
      integrate_views
      it "should show volunteer checkbox" do
        partner = Factory.create(:partner, :ask_for_volunteers => false)

        reg = Factory.create(:step_3_registrant, :partner_id => partner.to_param)
        get :show, :registrant_id => reg.to_param

        assert_select "#registrant_volunteer", 0
      end
    end
  end

  describe "#update" do
    before(:each) do
      @registrant = Factory.create(:step_3_registrant)
    end

    it "should update registrant and complete step 4" do
      put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_4_registrant)
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].step_4?
      assert_redirected_to registrant_step_5_url(assigns[:registrant])
    end

    it "should reject invalid input and show form again" do
      put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_4_registrant, :state_id_number => nil)
      assert assigns[:registrant].step_4?
      assert assigns[:registrant].reload.step_3?
      assert_template "show"
    end
  end
end
