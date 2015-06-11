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

describe MobileConfig do
  before(:each) do
    MobileConfig.redirect_url = nil
    MobileConfig.browsers = nil
    RockyConf.reload_from_files(
      Rails.root.join("spec/fixtures/files/mobile.yml").to_s
    )
  end
  after(:each) do
    RockyConf.reload_from_files(
      Rails.root.join("config", "settings.yml").to_s,
      Rails.root.join("config", "settings", "#{Rails.env}.yml").to_s,
    )
  end
  describe "#redirect_url" do
    it "returns the value from the config" do
      MobileConfig.redirect_url.should == "http://mob.rtv.com?partner=1"
    end
    it "appends query string from parameters" do
      MobileConfig.redirect_url(:partner=>'a').should == "http://mob.rtv.com?partner=a"
      MobileConfig.redirect_url(:partner=>'a', :source=>'b').should == "http://mob.rtv.com?partner=a&source=b"
      MobileConfig.redirect_url(:partner=>'', :source=>'b').should == "http://mob.rtv.com?partner=1&source=b"
      MobileConfig.redirect_url(:partner=>'2', :source=>'').should == "http://mob.rtv.com?partner=2"
    end
  end
  describe "#browsers" do
    it "returns an array of mobile browser names" do
      MobileConfig.browsers.should == ["android", "iphone"]
    end
  end
  describe "#is_mobile_request?(request)" do
    it "returns true when the request.user_agent matches one of the configured browsers" do
      req = spy(String)
      req.stub(:user_agent) { "Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30" }
      MobileConfig.is_mobile_request?(req).should be_truthy
      
      req.stub(:user_agent) { "Mozilla/5.0 (iPod; U; CPU iPhone OS 4_3_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5" }
      MobileConfig.is_mobile_request?(req).should be_truthy      
    end
    it "returns false when the request.user_agent doesn't match one of the configured browsers" do
      req = spy(String)
      req.stub(:user_agent) { "Mozilla/5.0 (Windows; U; Windows NT 6.1; zh-HK) AppleWebKit/533.18.1 (KHTML, like Gecko) Version/5.0.2 Safari/533.18.5" }
      MobileConfig.is_mobile_request?(req).should be_falsey
      
      req.stub(:user_agent) { "" }
      MobileConfig.is_mobile_request?(req).should be_falsey         
      req.stub(:user_agent) { nil }
      MobileConfig.is_mobile_request?(req).should be_falsey         
    end
  end
  
  
end
