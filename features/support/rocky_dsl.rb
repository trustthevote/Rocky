require 'webmock'

module RockyDsl
  
  def stub_partners
    # WebMock.stub_request(:any, %r{http://example-api\.com/api/v3/partners/\d+\.json}).to_return do |req|
    #   req.uri.to_s =~ /(\d+)\.json$/
    #   id = $1
    #   { "body"=> {"partner" => Partner.find(id).as_json} }
    # end
    
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get    "/api/v3/partners/1.json", {}, {:partner=>Partner.find(1).as_json}.to_json
    end
  end
  
end


World(RockyDsl)
