require 'webmock'

module RockyDsl
  
  def stub_partners
    WebMock.stub_request(:any, %r{http://example-api\.com/api/v3/partners/\d+\.json}).to_return do |req|
      req.uri.to_s =~ /(\d+)\.json$/
      id = $1
      {:body=>{:partner => V3::PartnerService.find(:partner_id=>id) }.to_json}
    end
    
  end
  
  def switch_partner_to_remote(registrant)
    registrant.remote_partner_id = registrant.partner_id
    registrant.partner_id = nil
  end
end


World(RockyDsl)
