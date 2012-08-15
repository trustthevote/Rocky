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

describe MobileConfig do
  describe "#redirect_url" do
    it "returns the value from the config" do
      stub(MobileConfig).config_file_path { File.join(RAILS_ROOT,"spec/fixtures/files/mobile.yml") }
      MobileConfig.redirect_url.should == "http://mob.rtv.com"
    end
  end
  describe "#browsers" do
    it "returns an array of mobile browser names" do
      stub(MobileConfig).config_file_path { File.join(RAILS_ROOT,"spec/fixtures/files/mobile.yml") }
      MobileConfig.browsers.should == ["android", "iphone"]
    end
    
  end
  
  
end
