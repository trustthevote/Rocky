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

require 'rails_helper'

describe WA do
  let(:root_url) { "https://weiapplets.sos.wa.gov/myvote/myvote" }
  it "should inherit from StateCustomization" do
    WA.superclass.should == StateCustomization
  end
  
  describe "online_reg_url(registrant)" do
    let(:wa) { WA.new(GeoState['WA']) }
    let(:reg) { double(Registrant) }
    context "when registrant is nil" do
      it "returns the root URL" do
        wa.online_reg_url(nil).should == root_url
      end
    end
    context "when registrant is not nill" do
      before(:each) do
        reg.stub(:first_name).and_return("First Name")
        reg.stub(:last_name).and_return("Last Name")
        reg.stub(:form_date_of_birth).and_return("01-01-1900")
        reg.stub(:locale).and_return('aa')
      end
      it "includes an escaped registrant first name, last name, DOB with '/' separators and locale" do
        wa.online_reg_url(reg).should ==
          "#{root_url}?language=aa&Org=RocktheVote&firstname=First+Name&lastname=Last+Name&DOB=01%2F01%2F1900"
      end
    end
  end
  
end
