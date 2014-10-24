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
  
  describe 'Caching' do
    before(:each) do
      RemotePartner.connection.stub(:get_without_cache).and_return(OpenStruct.new(body: "{
        \"partner\": {
          \"id\": \"1\"
        }
      }"))      
    end
    it "Reads from the API method if not cached" do
      Rails.cache.clear
      RemotePartner.connection.should_receive(:get_without_cache)
      p = RemotePartner.find(1)
    end
    it "Reads from the cache when there is a cached value" do
      p = RemotePartner.find(1)

      RemotePartner.connection.should_not_receive(:get_without_cache)
      p = RemotePartner.find(1)
      
    end
  end
  
  describe 'ActiveModel Simulation' do
    describe '.find_by_id' do
      before(:each) do
        RemotePartner.stub(:find).with(1).and_return(RemotePartner.new)
        RemotePartner.stub(:find).with(2) {
          raise "not found"
        } 
      end
      context 'when the partner exists' do
        it "returns the remote partner" do
          RemotePartner.find_by_id(1).should be_kind_of(RemotePartner)
        end
      end
      context 'when there is an error' do
        it "returns nil" do
          RemotePartner.find_by_id(2).should be_nil
        end
      end
    end
  end
  
end