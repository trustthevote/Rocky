require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Api::V2::PartnersController do

  describe 'show' do
    it 'should catch errors' do
      expect_api_error :message => 'error'
      partner { raise ArgumentError.new('error') }
    end

    it 'should return partner details' do
      expect_api_response :response 
      partner { :response }
    end
    
  end
  
  private
  
  def partner(&block)
    query = { :partner_id => nil, :partner_api_key => nil }
    mock(V2::PartnerService).find(query, &block)
    get :show, :format => 'json'
  end
  
end