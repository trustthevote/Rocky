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

describe TellFriendsController do
  describe "#create" do
    before(:each) do
      @registrant = Factory.create(:step_5_registrant)
    end

    it "should enqueue sending tell-a-friend email" do
      tell_params = {
        :tell_from => "Bob Dobbs",
        :tell_email => "bob@example.com",
        :tell_recipients => "arnold@example.com, obo@example.com",
        :tell_subject => "Register to vote the easy way",
        :tell_message => "I registered to vote and you can too."
      }

      assert_difference "Delayed::Job.count" do
        post :create, :registrant_id => @registrant.to_param, :tell_friend => tell_params
      end
      assert_not_nil assigns[:registrant]
      assert assigns[:email_sent]

      assert :success

      assert_not_nil assigns[:root_url_escaped]
      assert_template "finishes/show"
    end

    it "should show form again when fields are missing" do
      tell_params = {
        :tell_from => "Bob Dobbs",
        :tell_email => "",
        :tell_recipients => "",
        :tell_subject => "Register to vote the easy way",
        :tell_message => "I registered to vote and you can too."
      }

      assert_difference "Delayed::Job.count", 0 do
        post :create, :registrant_id => @registrant.to_param, :tell_friend => tell_params
      end
      assert_not_nil assigns[:registrant]
      assert !assigns[:email_sent]

      assert :success
      assert_template "finishes/show"
    end
  end
end
