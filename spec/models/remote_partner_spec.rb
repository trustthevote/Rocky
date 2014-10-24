require File.dirname(__FILE__) + '/../spec_helper'

describe RemotePartner do
  
  
  it "shoud be an active resource" do
    RemotePartner.new.should be_kind_of(ActiveResource::Base)
  end
  
  describe 'API endpoint' do
    it "should use the config for api hostname" do
      RemotePartner.site.to_s.should == RockyConf.api_host_name
    end
    it "should use the API prefix for v3" do
      RemotePartner.prefix.should == "/api/v3/"
    end  
    it "should use 'partner' as the element name" do
      RemotePartner.element_name.should == "partner"
    end
  end
  
  
end