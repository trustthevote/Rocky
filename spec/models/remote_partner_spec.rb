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
      ActiveResource::Connection.cache.clear
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
    describe 'to_param' do
      it "returns id" do
        r = RemotePartner.new
        r.should_receive(:id)
        r.to_param
      end
    end
    describe 'custom_logo?' do
      it "returns custom_logo" do
        r = RemotePartner.new
        r.should_receive(:custom_logo)
        r.custom_logo?
      end
      
    end
    
    describe 'expected attributes from partner model' do
      subject { RemotePartner.new }
      Partner.column_names.each do |method|
        it { should respond_to(method) }
        it { should respond_to("#{method}=") }
      end
    end
    describe 'additional expected methods from partner model' do
      subject { RemotePartner.new }
      [:custom_logo, :header_logo_url].each do |method|
        it { should respond_to(method)}
      end
    end
  end
  
end