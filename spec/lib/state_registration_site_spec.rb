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
require File.dirname(__FILE__) + '/../spec_helper'

describe StateRegistrationSite do
  describe "transfer voter registration to state site" do
    it "short-circuits when not transferable" do
      reg = Factory.create(:step_3_registrant, :home_zip_code => "15215", :party => "Republican")
      site = StateRegistrationSite.new(reg)
      assert_nil site.transfer
    end

    if ENV['INTEGRATE_COLORADO']
      puts "(Running external integration tests for Colorado reg site)"
      describe "external integration" do
        it "returns the redirect location" do
          reg = Factory.create(:step_3_registrant, :home_zip_code => "80202", :party => "Republican")
          # keep sensitive personal test info in memory only, not in DB or test log
          reg.attributes = YAML.load_file("reg_colorado.yml")[:real]
          assert reg.valid?
          site = StateRegistrationSite.new(reg)
          assert_match %r{/Voter/editVoterDetails\.do}, site.transfer
        end

        it "returns nil when registrant not a valid voter" do
          # "1111" is not valid CO drivers license number
          reg = Factory.create(:step_3_registrant, :home_zip_code => "80202", :party => "Republican", :state_id_number => "1111")
          site = StateRegistrationSite.new(reg)
          assert_nil site.transfer
        end
      end
    end
  end
end
