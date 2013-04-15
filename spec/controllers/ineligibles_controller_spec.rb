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

describe IneligiblesController do
  integrate_views

  describe "when 18 or over" do
    it "shows not-a-citizen message" do
      @registrant = FactoryGirl.create(:step_1_registrant, :us_citizen => false)
      get :show, :registrant_id => @registrant.to_param
      assert_not_nil assigns[:registrant]
      assert_response :success
      assert_select "p.reason", /citizen/
    end

    it "shows state-not-participating message" do
      @registrant = FactoryGirl.create(:step_1_registrant, :home_zip_code => "58111")
      get :show, :registrant_id => @registrant.to_param
      assert_not_nil assigns[:registrant]
      assert_response :success
      assert_select "p.reason", /does not register voters/
    end
  end

  describe "when under 18" do
    it "don't show under-18 page if ineligble in other ways" do
      @registrant = FactoryGirl.create(:step_1_registrant, :us_citizen => false, :date_of_birth => 16.years.ago.to_date.strftime("%m/%d/%Y"))
      get :show, :registrant_id => @registrant.to_param
      assert_response :success
      assert_template "show"
    end

    it "shows state localized sub_18 message" do
      @registrant = FactoryGirl.create(:step_1_registrant, :date_of_birth => 16.years.ago.to_date.strftime("%m/%d/%Y"), :opt_in_email=>true)
      assert @registrant.ineligible_age?
      get :show, :registrant_id => @registrant.to_param
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].remind_when_18
      assert assigns[:registrant].opt_in_email
      assert_response :success
      assert_template "under_18"
      assert_match Regexp.new(@registrant.localization.sub_18), response.body
    end
  end
end
