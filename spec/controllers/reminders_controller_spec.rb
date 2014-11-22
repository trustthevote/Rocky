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


describe RemindersController do
  include Rails.application.routes.url_helpers
  render_views

  before(:each) do
    Partner.any_instance.stub(:valid_api_key?).and_return(true)
  end

  describe "stop reminders" do
    let(:uid) { "param" }
    before(:each) do
      Registrant.stub(:stop_reminders).and_return({
        :first_name=>"FN",
        :last_name=>"LN",
        :email_address=>"email",
        :reminders_stopped=>true
      })
    end
    it "stops remaining emails from coming" do
      Registrant.should_receive(:stop_reminders).with(uid)
      get :stop, :id => uid
    end
    
    context 'when stop-reminders fails' do
      before(:each) do
        Registrant.stub(:stop_reminders).and_return({
          :first_name=>"FN",
          :last_name=>"LN",
          :email_address=>"email",
          :reminders_stopped=>false
        })
      end
      it "displays an error message"
    end

    describe "feedback page" do
      render_views
      it "should show thank you message" do
        reg = FactoryGirl.create(:completed_registrant, :reminders_left => 2)
        get :stop, :id => reg.to_param
        assert_select "h1", "Thanks for Registering!"
      end
    end
  end

end
